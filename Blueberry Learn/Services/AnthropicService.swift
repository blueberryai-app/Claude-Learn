import Foundation
import SwiftAnthropic

class AnthropicService {
    private let apiKey: String
    private let service: any SwiftAnthropic.AnthropicService

    // Use configuration file for API key
    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? APIConfiguration.anthropicAPIKey
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
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        frustrationSignal: Bool = false
    ) async throws -> AsyncThrowingStream<String, Error> {
        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt,
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            frustrationSignal: frustrationSignal
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
            stream: true
        )

        print("🔵 [AnthropicService] Calling service.streamMessage...")
        let stream = try await service.streamMessage(parameters)
        print("🟢 [AnthropicService] Stream created successfully")

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await event in stream {
                        if let text = event.delta?.text {
                            continuation.yield(text)
                        }
                    }
                    print("🟢 [AnthropicService] Stream finished successfully")
                    continuation.finish()
                } catch {
                    print("🔴 [AnthropicService] Stream error: \(error)")
                    print("🔴 [AnthropicService] Error type: \(type(of: error))")
                    print("🔴 [AnthropicService] Error localized: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("🔴 [AnthropicService] NSError domain: \(nsError.domain)")
                        print("🔴 [AnthropicService] NSError code: \(nsError.code)")
                        print("🔴 [AnthropicService] NSError userInfo: \(nsError.userInfo)")
                    }
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // Send a regular message (non-streaming)
    func sendMessage(
        prompt: String,
        context: [ChatMessage],
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        frustrationSignal: Bool = false
    ) async throws -> String {
        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt,
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            frustrationSignal: frustrationSignal
        )

        let parameters = MessageParameter(
            model: .other(APIConfiguration.claudeModel),
            messages: messages,
            maxTokens: APIConfiguration.maxTokens
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

    // Build message history for API call
    private func buildMessageHistory(
        context: [ChatMessage],
        currentPrompt: String,
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        frustrationSignal: Bool = false
    ) -> [MessageParameter.Message] {
        var messages: [MessageParameter.Message] = []

        // Get system prompt with timing info
        let systemPrompt = buildSystemPrompt(
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            frustrationSignal: frustrationSignal
        )

        // Add system prompt as first message (user/assistant pair)
        messages.append(MessageParameter.Message(
            role: .user,
            content: .text("System: \(systemPrompt)")
        ))
        messages.append(MessageParameter.Message(
            role: .assistant,
            content: .text("Understood. I'll follow those instructions for our conversation.")
        ))

        // Add conversation history (limit to last 10 messages for context window)
        let recentContext = context.suffix(10)
        for message in recentContext {
            let role: MessageParameter.Message.Role = message.role == .user ? .user : .assistant
            messages.append(MessageParameter.Message(
                role: role,
                content: .text(message.content)
            ))
        }

        // Add current user prompt
        messages.append(MessageParameter.Message(
            role: .user,
            content: .text(currentPrompt)
        ))

        return messages
    }

    // Build system prompt based on current settings
    private func buildSystemPrompt(
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil,
        sessionTimerDescription: String? = nil,
        frustrationSignal: Bool = false
    ) -> String {
        // Use the PromptManager for consistent prompt generation
        return PromptManager.shared.getSystemPrompt(
            for: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName,
            sessionTimerDescription: sessionTimerDescription,
            frustrationSignal: frustrationSignal
        )
    }
}
