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

    let space: LearningSpace
    private let storageService = StorageService.shared

    init(space: LearningSpace) {
        self.space = space
        loadMessages()
    }

    func loadMessages() {
        messages = storageService.loadMessages(for: space.id)
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Add user message
        let userMessage = ChatMessage(
            content: inputText,
            role: .user,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(userMessage)
        storageService.addMessage(userMessage, to: space.id)

        let currentInput = inputText
        inputText = ""

        // Simulate AI response (for POC)
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            let responseText = self.generateMockResponse(to: currentInput)
            let assistantMessage = ChatMessage(
                content: responseText,
                role: .assistant,
                spaceId: self.space.id,
                activeMode: self.currentMode,
                activeLens: self.currentLens?.name
            )
            self.messages.append(assistantMessage)
            self.storageService.addMessage(assistantMessage, to: self.space.id)
            self.isLoading = false
        }
    }

    func switchMode(_ mode: LearningMode) {
        currentMode = mode
        if mode == .customEntity {
            showCustomEntityAlert = true
        }
    }

    func applyLens(_ lens: LearningLens?) {
        currentLens = lens
    }

    private func generateMockResponse(to input: String) -> String {
        // Mock responses based on mode
        switch currentMode {
        case .standard:
            return "That's an interesting question about \(space.name). Let me help you understand this concept better..."
        case .writing:
            return "Let's work on improving your writing. Consider starting with a clear thesis statement and supporting it with evidence..."
        case .debate:
            return "I see your point, but let me present an alternative perspective on this topic..."
        case .customEntity:
            let entity = customEntityName.isEmpty ? "Einstein" : customEntityName
            return "[\(entity)] Ah, what a fascinating question! In my experience..."
        case .quiz:
            return "Great! Let's test your knowledge with a question: What is the primary function of...?"
        }
    }
}
