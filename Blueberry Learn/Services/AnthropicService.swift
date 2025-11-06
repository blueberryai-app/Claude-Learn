import Foundation
import SwiftAnthropic

class AnthropicService {
    private let apiKey: String
    private let service: any SwiftAnthropic.AnthropicService

    // Use configuration file for API key
    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? APIConfiguration.anthropicAPIKey

        // Debug: Check API key
        print("🔑 API Key configured: \(self.apiKey.prefix(10))...") // Only show first 10 chars for security
        print("   Key length: \(self.apiKey.count)")

        self.service = AnthropicServiceFactory.service(
            apiKey: self.apiKey,
            betaHeaders: nil
        )
    }

    // Stream a message with conversation context
    func streamMessage(
        prompt: String,
        context: [ChatMessage],
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil
    ) async throws -> AsyncThrowingStream<String, Error> {
        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt,
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName
        )

        let parameters = MessageParameter(
            model: .other(APIConfiguration.claudeModel),
            messages: messages,
            maxTokens: APIConfiguration.maxTokens,
            stream: true
        )

        // Debug: Print the parameters being sent
        print("🔍 DEBUG - Streaming Message Parameters:")
        print("  Model: \(parameters.model)")
        print("  Messages count: \(parameters.messages.count)")
        print("  Max tokens: \(parameters.maxTokens)")
        print("  First few messages:")
        for (index, message) in parameters.messages.prefix(3).enumerated() {
            print("    Message \(index): Role=\(message.role)")
        }

        do {
            let stream = try await service.streamMessage(parameters)

            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await event in stream {
                            if let text = event.delta?.text {
                                continuation.yield(text)
                            }
                        }
                        continuation.finish()
                    } catch {
                        print("❌ Stream error: \(error)")
                        continuation.finish(throwing: error)
                        }
                }
            }
        } catch {
            print("❌ Failed to create stream: \(error)")
            print("   Error type: \(type(of: error))")
            if let apiError = error as? SwiftAnthropic.APIError {
                print("   API Error details: \(apiError)")
            }
            throw error
        }
    }

    // Send a regular message (non-streaming)
    func sendMessage(
        prompt: String,
        context: [ChatMessage],
        space: LearningSpace,
        mode: LearningMode,
        lens: LearningLens?,
        customEntityName: String? = nil
    ) async throws -> String {
        let messages = buildMessageHistory(
            context: context,
            currentPrompt: prompt,
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName
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
        customEntityName: String? = nil
    ) -> [MessageParameter.Message] {
        var messages: [MessageParameter.Message] = []

        // Get system prompt
        let systemPrompt = buildSystemPrompt(
            space: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName
        )

        print("📝 System prompt preview (first 200 chars):")
        print("   \(String(systemPrompt.prefix(200)))...")

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
        customEntityName: String? = nil
    ) -> String {
        // Use the PromptManager for consistent prompt generation
        return PromptManager.shared.getSystemPrompt(
            for: space,
            mode: mode,
            lens: lens,
            customEntityName: customEntityName
        )
    }
}
