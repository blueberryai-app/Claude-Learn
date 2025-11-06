import Foundation
import SwiftUI
import Combine

class SpaceDetailViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false

    let space: LearningSpace
    private let storageService = StorageService.shared

    init(space: LearningSpace) {
        self.space = space
        loadSessions()
    }

    func loadSessions() {
        sessions = storageService.loadSessions(for: space.id)
    }

    func createNewSession() -> ChatSession {
        let session = storageService.createSession(for: space.id)
        loadSessions() // Reload to get updated list
        return session
    }

    func deleteSession(_ session: ChatSession) {
        storageService.deleteSession(session.id, from: space.id)
        loadSessions() // Reload to reflect deletion
    }

    func deleteSessionAtOffsets(_ offsets: IndexSet) {
        for index in offsets {
            let session = sessions[index]
            deleteSession(session)
        }
    }
}