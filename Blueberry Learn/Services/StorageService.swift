import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard

    private let sessionsKey = "chatSessions"
    private let messagesKeyPrefix = "messages_"

    private init() {}

    // MARK: - Chat Sessions
    func saveSessions(_ sessions: [ChatSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }

    func loadSessions() -> [ChatSession] {
        guard let data = userDefaults.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([ChatSession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.lastMessageDate > $1.lastMessageDate }
    }

    func createSession() -> ChatSession {
        let session = ChatSession()
        var sessions = loadSessions()
        sessions.append(session)
        saveSessions(sessions)
        return session
    }

    func updateSession(_ session: ChatSession) {
        var sessions = loadSessions()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions(sessions)
        } else {
            // If session doesn't exist, add it
            sessions.append(session)
            saveSessions(sessions)
        }
    }

    func deleteSession(_ sessionId: UUID) {
        var sessions = loadSessions()
        sessions.removeAll { $0.id == sessionId }
        saveSessions(sessions)

        // Also delete associated messages
        let messagesKey = messagesKeyPrefix + sessionId.uuidString
        userDefaults.removeObject(forKey: messagesKey)
    }

    func getSession(_ sessionId: UUID) -> ChatSession? {
        let sessions = loadSessions()
        return sessions.first { $0.id == sessionId }
    }

    // MARK: - Chat Messages
    func saveMessages(_ messages: [ChatMessage], for sessionId: UUID) {
        let key = messagesKeyPrefix + sessionId.uuidString
        if let encoded = try? JSONEncoder().encode(messages) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func loadMessages(for sessionId: UUID) -> [ChatMessage] {
        let key = messagesKeyPrefix + sessionId.uuidString
        guard let data = userDefaults.data(forKey: key),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            // Return welcome message if no messages exist
            let welcomeMessage = ChatMessage.mockWelcomeMessage()
            return [welcomeMessage]
        }
        return messages
    }

    func addMessage(_ message: ChatMessage, to sessionId: UUID) {
        var messages = loadMessages(for: sessionId)
        messages.append(message)
        saveMessages(messages, for: sessionId)
    }

    // MARK: - Clear Data (for development)
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }

    // MARK: - Migration Support
    // This method helps migrate old data structure if needed
    func migrateDataIfNeeded() {
        // Check if there's old space-based data to migrate
        // For now, we'll just start fresh, but this is where migration logic would go
        // if we needed to preserve existing user data
    }
}