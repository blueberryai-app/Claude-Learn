import Foundation

struct ChatMessage: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var content: String  // Changed to var for streaming updates
    let role: MessageRole
    let timestamp: Date
    var activeMode: LearningMode?
    var activeLens: String? // For POC, just store lens name as string
    var quizData: QuizResponse? // Parsed quiz JSON data
    var isHidden: Bool // Messages that are sent to API but not shown in UI

    enum MessageRole: String, Codable {
        case user
        case assistant
    }

    init(content: String, role: MessageRole, activeMode: LearningMode? = nil, activeLens: String? = nil, quizData: QuizResponse? = nil, isHidden: Bool = false) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.activeMode = activeMode
        self.activeLens = activeLens
        self.quizData = quizData
        self.isHidden = isHidden
    }
}

// MARK: - Mock Data
extension ChatMessage {
    static func mockWelcomeMessage() -> ChatMessage {
        return ChatMessage(
            content: "Hello! I'm Claude, your AI tutor and education assistant. I'm here to help you learn, explore ideas, and develop your understanding. What would you like to work on today?",
            role: .assistant
        )
    }
}