import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard

    private let spacesKey = "learningSpaces"
    private let messagesKeyPrefix = "messages_"

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

    // MARK: - Clear Data (for development)
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }
}