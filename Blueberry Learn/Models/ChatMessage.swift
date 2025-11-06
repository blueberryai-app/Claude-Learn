import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let role: MessageRole
    let timestamp: Date
    let spaceId: UUID
    var activeMode: LearningMode?
    var activeLens: String? // For POC, just store lens name as string

    enum MessageRole: String, Codable {
        case user
        case assistant
    }

    init(content: String, role: MessageRole, spaceId: UUID, activeMode: LearningMode? = nil, activeLens: String? = nil) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.spaceId = spaceId
        self.activeMode = activeMode
        self.activeLens = activeLens
    }
}

// MARK: - Mock Data
extension ChatMessage {
    static func mockWelcomeMessage(for space: LearningSpace) -> ChatMessage {
        let welcomeMessages = [
            "Physics - Mech": "Welcome to Physics! I'm here to help you understand mechanics. What would you like to explore today - forces, motion, energy, or something else?",
            "Electrical Eng": "Hello! Ready to dive into electrical engineering? We can explore circuits, signals, power systems, or any other electrical concepts you're curious about.",
            "Literature": "Welcome to your literature space! Whether you're analyzing a specific text or exploring literary themes, I'm here to guide your journey through the written word.",
            "Writing": "Let's work on your writing together! Whether it's essays, creative writing, or improving your style, I'm here to help you express yourself clearly and effectively.",
            "Biology": "Welcome to Biology! From molecules to ecosystems, let's explore the fascinating world of life sciences. What aspect of biology interests you today?"
        ]

        return ChatMessage(
            content: welcomeMessages[space.name] ?? "What are we learning today?",
            role: .assistant,
            spaceId: space.id
        )
    }
}