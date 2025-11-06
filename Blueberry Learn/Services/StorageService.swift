import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard

    private let spacesKey = "learningSpaces"
    private let messagesKeyPrefix = "messages_"
    private let sessionsKeyPrefix = "sessions_"

    private init() {}

    // MARK: - Learning Spaces
    func saveLearningSpaces(_ spaces: [LearningSpace]) {
        if let encoded = try? JSONEncoder().encode(spaces) {
            userDefaults.set(encoded, forKey: spacesKey)
        }
    }

    func loadLearningSpaces() -> [LearningSpace] {
        guard let data = userDefaults.data(forKey: spacesKey),
              let spaces = try? JSONDecoder().decode([LearningSpace].self, from: data) else {
            // Return mock data on first launch
            let mockSpaces = LearningSpace.mockSpaces
            saveLearningSpaces(mockSpaces)
            return mockSpaces
        }
        return spaces
    }

    func addLearningSpace(_ space: LearningSpace) {
        var spaces = loadLearningSpaces()
        spaces.append(space)
        saveLearningSpaces(spaces)
    }

    func updateLearningSpace(_ space: LearningSpace) {
        var spaces = loadLearningSpaces()
        if let index = spaces.firstIndex(where: { $0.id == space.id }) {
            spaces[index] = space
            saveLearningSpaces(spaces)
        }
    }

    // MARK: - Chat Messages
    func saveMessages(_ messages: [ChatMessage], for spaceId: UUID) {
        let key = messagesKeyPrefix + spaceId.uuidString
        if let encoded = try? JSONEncoder().encode(messages) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func loadMessages(for spaceId: UUID) -> [ChatMessage] {
        let key = messagesKeyPrefix + spaceId.uuidString
        guard let data = userDefaults.data(forKey: key),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            // Return welcome message if no messages exist
            if let space = loadLearningSpaces().first(where: { $0.id == spaceId }) {
                let welcomeMessage = ChatMessage.mockWelcomeMessage(for: space)
                return [welcomeMessage]
            }
            return []
        }
        return messages
    }

    func addMessage(_ message: ChatMessage, to spaceId: UUID) {
        var messages = loadMessages(for: spaceId)
        messages.append(message)
        saveMessages(messages, for: spaceId)
    }

    // MARK: - Chat Sessions
    func saveSessions(_ sessions: [ChatSession], for spaceId: UUID) {
        let key = sessionsKeyPrefix + spaceId.uuidString
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func loadSessions(for spaceId: UUID) -> [ChatSession] {
        let key = sessionsKeyPrefix + spaceId.uuidString
        guard let data = userDefaults.data(forKey: key),
              let sessions = try? JSONDecoder().decode([ChatSession].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.lastMessageDate > $1.lastMessageDate }
    }

    func createSession(for spaceId: UUID) -> ChatSession {
        let session = ChatSession(spaceId: spaceId)
        var sessions = loadSessions(for: spaceId)
        sessions.append(session)
        saveSessions(sessions, for: spaceId)
        return session
    }

    func updateSession(_ session: ChatSession) {
        var sessions = loadSessions(for: session.spaceId)
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions(sessions, for: session.spaceId)
        } else {
            // If session doesn't exist, add it
            sessions.append(session)
            saveSessions(sessions, for: session.spaceId)
        }
    }

    func deleteSession(_ sessionId: UUID, from spaceId: UUID) {
        var sessions = loadSessions(for: spaceId)
        sessions.removeAll { $0.id == sessionId }
        saveSessions(sessions, for: spaceId)
    }

    func getSession(_ sessionId: UUID, from spaceId: UUID) -> ChatSession? {
        let sessions = loadSessions(for: spaceId)
        return sessions.first { $0.id == sessionId }
    }

    // MARK: - Clear Data (for development)
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }
}