import Foundation

struct ChatSession: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    let createdDate: Date
    var lastMessageDate: Date
    var messages: [ChatMessage]

    init(messages: [ChatMessage] = []) {
        self.id = UUID()
        self.createdDate = Date()
        self.lastMessageDate = Date()
        self.messages = messages

        // Auto-generate title from first user message if available
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            self.title = ChatSession.generateTitle(from: firstUserMessage.content)
        } else {
            self.title = "New Chat"
        }
    }

    // Generate a title from the first message (truncate if too long)
    static func generateTitle(from message: String) -> String {
        let cleaned = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty {
            return "New Chat"
        }

        // Take first 50 characters or up to first line break
        let maxLength = 50
        let firstLine = cleaned.components(separatedBy: .newlines).first ?? cleaned

        if firstLine.count <= maxLength {
            return firstLine
        } else {
            let truncated = String(firstLine.prefix(maxLength))
            // Try to break at last word boundary
            if let lastSpace = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpace]) + "..."
            }
            return truncated + "..."
        }
    }

    // Update title based on messages
    mutating func updateTitle() {
        if let firstUserMessage = messages.first(where: { $0.role == .user }) {
            self.title = ChatSession.generateTitle(from: firstUserMessage.content)
        }
    }

    // Get a preview of the last message
    var lastMessagePreview: String {
        guard let lastMessage = messages.last else {
            return "No messages yet"
        }

        let preview = lastMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let maxLength = 100

        if preview.count <= maxLength {
            return preview
        } else {
            return String(preview.prefix(maxLength)) + "..."
        }
    }

    // Format the date for display
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastMessageDate, relativeTo: Date())
    }
}

// MARK: - Mock Data
extension ChatSession {
    static func mockSession() -> ChatSession {
        let messages = [
            ChatMessage(content: "What is Newton's first law?", role: .user),
            ChatMessage(content: "Newton's first law, also known as the law of inertia, states that an object at rest stays at rest and an object in motion stays in motion at the same speed and in the same direction unless acted upon by an unbalanced force.", role: .assistant)
        ]

        var session = ChatSession(messages: messages)
        session.updateTitle()
        return session
    }
}