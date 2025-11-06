import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var currentMode: LearningMode = .standard
    @Published var currentLens: LearningLens? = nil
    @Published var isShowingModeSelection = false
    @Published var isLoading = false
    @Published var customEntityName = ""
    @Published var showCustomEntityAlert = false
    @Published var streamingMessageContent = ""
    @Published var errorMessage: String?

    let space: LearningSpace
    var session: ChatSession
    private let storageService = StorageService.shared
    private let anthropicService = AnthropicService()
    private let promptManager = PromptManager.shared
    private var streamingTask: Task<Void, Never>?

    init(space: LearningSpace, sessionId: UUID? = nil) {
        self.space = space

        // Load existing session or create new one
        if let sessionId = sessionId,
           let existingSession = storageService.getSession(sessionId, from: space.id) {
            self.session = existingSession
        } else {
            // Create a new session if no sessionId provided
            self.session = storageService.createSession(for: space.id)
        }

        loadMessages()
    }

    func loadMessages() {
        messages = session.messages
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Cancel any existing streaming task
        streamingTask?.cancel()

        // Add user message
        let userMessage = ChatMessage(
            content: inputText,
            role: .user,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(userMessage)

        // Update session with new message
        session.messages.append(userMessage)
        session.lastMessageDate = Date()
        session.updateTitle() // Update title if this is first message
        storageService.updateSession(session)

        let currentInput = inputText
        inputText = ""
        errorMessage = nil
        streamingMessageContent = ""
        isLoading = true

        // Create a placeholder for the assistant's response
        let assistantMessage = ChatMessage(
            content: "",
            role: .assistant,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(assistantMessage)

        // Add empty assistant message to session
        session.messages.append(assistantMessage)

        // Start streaming response
        streamingTask = Task {
            do {
                let stream = try await anthropicService.streamMessage(
                    prompt: currentInput,
                    context: Array(messages.dropLast(2)), // Exclude the user message we just added and empty assistant message
                    space: space,
                    mode: currentMode,
                    lens: currentLens,
                    customEntityName: currentMode == .mimic ? customEntityName : nil
                )

                var fullResponse = ""
                for try await chunk in stream {
                    fullResponse += chunk
                    await MainActor.run {
                        self.streamingMessageContent = fullResponse
                        // Update the last message with streaming content
                        if let lastIndex = self.messages.indices.last {
                            self.messages[lastIndex].content = fullResponse
                        }
                    }
                }

                // Save the complete message
                await MainActor.run {
                    if let lastIndex = self.messages.indices.last {
                        self.messages[lastIndex].content = fullResponse

                        // Update session with assistant's response
                        self.session.messages[lastIndex].content = fullResponse
                        self.session.lastMessageDate = Date()
                        self.storageService.updateSession(self.session)
                    }
                    self.isLoading = false
                    self.streamingMessageContent = ""
                }
            } catch {
                await MainActor.run {
                    // Create more user-friendly error messages
                    var errorMessage = "Failed to get response"

                    if (error as NSError).code == -1009 {
                        errorMessage = "No internet connection. Please check your network."
                    } else if error.localizedDescription.contains("401") || error.localizedDescription.contains("authentication") {
                        errorMessage = "Invalid API key. Please check your API key in APIConfiguration.swift"
                    } else if error.localizedDescription.contains("429") {
                        errorMessage = "Rate limit exceeded. Please wait a moment and try again."
                    } else {
                        errorMessage += ": \(error.localizedDescription)"
                    }

                    self.errorMessage = errorMessage
                    self.isLoading = false
                    // Remove the empty assistant message on error
                    if self.messages.last?.content.isEmpty == true {
                        self.messages.removeLast()
                    }
                }
            }
        }
    }

    func switchMode(_ mode: LearningMode) {
        currentMode = mode
        if mode == .mimic {
            showCustomEntityAlert = true
        }
    }

    func applyLens(_ lens: LearningLens?) {
        currentLens = lens
    }

    func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        isLoading = false
    }

    deinit {
        streamingTask?.cancel()
    }
}
