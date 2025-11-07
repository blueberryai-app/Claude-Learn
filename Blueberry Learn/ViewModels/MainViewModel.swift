import Foundation
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var isLoading = false

    private let storageService = StorageService.shared

    init() {
        loadSessions()
    }

    func loadSessions() {
        sessions = storageService.loadSessions()
    }

    func deleteSession(_ session: ChatSession) {
        storageService.deleteSession(session.id)
        loadSessions() // Reload to reflect deletion
    }
}