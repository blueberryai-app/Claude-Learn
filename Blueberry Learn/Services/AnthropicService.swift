import Foundation
import SwiftAnthropic

class AnthropicService {
    private let apiKey: String
    private let service: any SwiftAnthropic.AnthropicService

    // Use configuration file for API key
    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? APIConfiguration.activeAPIKey
        self.service = AnthropicServiceFactory.service(
            apiKey: self.apiKey,
            betaHeaders: nil
        )

        print("🔵 [AnthropicService] Initialized")
        print("🔵 [AnthropicService] API Key length: \(self.apiKey.count)")
        print("🔵 [AnthropicService] API Key prefix: \(String(self.apiKey.prefix(15)))...")
        print("🔵 [AnthropicService] Model: \(APIConfiguration.claudeModel)")
    }

    // Stream a message with conversation context
    func streamMessage(
        prompt: String,
        context: [ChatMessage],
        mode: LearningMode,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        quizType: QuizType? = nil,
        isModeSwitching: Bool = false
    ) async throws -> AsyncThrowingStream<String, Error> {
        let systemPrompt = buildSystemPrompt(
            mode: mode,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            quizType: quizType,
            isModeSwitching: isModeSwitching
        )

        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt
        )

        print("🔵 [AnthropicService] Preparing to stream message")
        print("🔵 [AnthropicService] API Key (first 10 chars): \(String(apiKey.prefix(10)))...")
        print("🔵 [AnthropicService] Model: \(APIConfiguration.claudeModel)")
        print("🔵 [AnthropicService] Max Tokens: \(APIConfiguration.maxTokens)")
        print("🔵 [AnthropicService] Number of messages: \(messages.count)")
        print("🔵 [AnthropicService] Current prompt: \(prompt.prefix(100))...")

        let parameters = MessageParameter(
            model: .other(APIConfiguration.claudeModel),
            messages: messages,
            maxTokens: APIConfiguration.maxTokens,
            system: .text(systemPrompt)
        )

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    print("🔵 [AnthropicService] Calling createMessage with streaming")
                    let stream = try await service.streamMessage(parameters)

                    print("🔵 [AnthropicService] Stream received, iterating over chunks")
                    for try await message in stream {
                        if let content = message.delta?.text {
                            continuation.yield(content)
                        }
                    }
                    print("🟢 [AnthropicService] Stream completed successfully")
                    continuation.finish()
                } catch {
                    print("🔴 [AnthropicService] Stream error: \(error)")
                    print("🔴 [AnthropicService] Error type: \(type(of: error))")
                    print("🔴 [AnthropicService] Error description: \(error.localizedDescription)")

                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // Send a regular message (non-streaming)
    func sendMessage(
        prompt: String,
        context: [ChatMessage],
        mode: LearningMode,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        quizType: QuizType? = nil,
        isModeSwitching: Bool = false
    ) async throws -> String {
        let systemPrompt = buildSystemPrompt(
            mode: mode,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            quizType: quizType,
            isModeSwitching: isModeSwitching
        )

        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt
        )

        let parameters = MessageParameter(
            model: .other(APIConfiguration.claudeModel),
            messages: messages,
            maxTokens: APIConfiguration.maxTokens,
            system: .text(systemPrompt)
        )

        let response = try await service.createMessage(parameters)

        // Extract text from the response content
        if let content = response.content.first {
            switch content {
            case .text(let text):
                return text
            default:
                return ""
            }
        }
        return ""
    }

    // Generate a concise 2-3 word title from the first user message
    func generateChatTitle(from firstMessage: String) async throws -> String {
        print("🔵 [AnthropicService] Generating chat title for: \(firstMessage.prefix(50))...")

        let titlePrompt = """
        Generate a concise 2-3 word title that captures the essence of this question or message. \
        Only respond with the title itself, nothing else.

        Message: \(firstMessage)
        """

        let messages: [MessageParameter.Message] = [
            MessageParameter.Message(
                role: .user,
                content: .text(titlePrompt)
            )
        ]

        let parameters = MessageParameter(
            model: .other(APIConfiguration.claudeModel),
            messages: messages,
            maxTokens: 20  // Keep it short - we only need 2-3 words
        )

        let response = try await service.createMessage(parameters)

        // Extract text from the response content
        if let content = response.content.first {
            switch content {
            case .text(let text):
                let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
                print("🟢 [AnthropicService] Generated title: \(title)")
                return title
            default:
                print("🔴 [AnthropicService] Unexpected response format for title generation")
                throw NSError(domain: "AnthropicService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }
        }

        print("🔴 [AnthropicService] Empty response for title generation")
        throw NSError(domain: "AnthropicService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
    }

    // Build message history for API call
    private func buildMessageHistory(
        context: [ChatMessage],
        currentPrompt: String
    ) -> [MessageParameter.Message] {
        var messages: [MessageParameter.Message] = []

        // Add conversation history (limit to last 10 messages for context window)
        let recentContext = context.suffix(10)
        for message in recentContext {
            let role: MessageParameter.Message.Role = message.role == .user ? .user : .assistant

            // For messages with empty content (quiz JSON that was cleared),
            // reconstruct a readable summary from quizData
            var contentText = message.content
            if contentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let quizData = message.quizData {
                contentText = reconstructQuizContent(from: quizData)
                print("🔵 [AnthropicService] Reconstructed quiz content from quizData")
            }

            messages.append(MessageParameter.Message(
                role: role,
                content: .text(contentText)
            ))
        }

        // Add current prompt
        messages.append(MessageParameter.Message(
            role: .user,
            content: .text(currentPrompt)
        ))

        return messages
    }

    // Reconstruct readable content from quiz data for API context
    private func reconstructQuizContent(from quizData: QuizResponse) -> String {
        switch quizData.type {
        case .question:
            var text = ""
            if let preamble = quizData.preamble {
                text += preamble + "\n\n"
            }
            if let questionText = quizData.questionText {
                text += questionText
            }
            if let hint = quizData.hint {
                text += "\n\nHint: \(hint)"
            }
            return text.isEmpty ? "[Quiz Question]" : text

        case .feedback:
            var text = "[Quiz Feedback]"
            if let explanation = quizData.explanation {
                text = explanation
            }
            if let encouragement = quizData.encouragement {
                text += "\n\n\(encouragement)"
            }
            return text

        case .quizComplete:
            var text = "[Quiz Complete]"
            if let summary = quizData.summary {
                text = summary
            }
            if let closingMessage = quizData.closingMessage {
                text += "\n\n\(closingMessage)"
            }
            return text

        case .quizStart:
            if let topic = quizData.topic {
                return "Starting quiz on: \(topic)"
            }
            return "[Quiz Started]"
        }
    }

    // Build system prompt
    private func buildSystemPrompt(
        mode: LearningMode,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        quizType: QuizType? = nil,
        isModeSwitching: Bool = false
    ) -> String {
        // Use the PromptManager for consistent prompt generation
        return PromptManager.shared.getSystemPrompt(
            mode: mode,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            quizType: quizType,
            isModeSwitching: isModeSwitching
        )
    }
}