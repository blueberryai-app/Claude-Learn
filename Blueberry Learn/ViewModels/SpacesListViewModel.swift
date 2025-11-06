import Foundation
import SwiftUI
import Combine

class SpacesListViewModel: ObservableObject {
    @Published var spaces: [LearningSpace] = []
    @Published var searchText = ""
    @Published var isShowingCreateSpace = false

    private let storageService = StorageService.shared

    var filteredSpaces: [LearningSpace] {
        if searchText.isEmpty {
            return spaces
        }
        return spaces.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        loadSpaces()
    }

    func loadSpaces() {
        spaces = storageService.loadLearningSpaces()
    }

    func createSpace(name: String, icon: String, systemPrompt: String) {
        let newSpace = LearningSpace(
            name: name,
            icon: icon,
            systemPrompt: systemPrompt
        )
        storageService.addLearningSpace(newSpace)
        spaces.append(newSpace)
        isShowingCreateSpace = false
    }

    func updateSpaceAccessTime(_ space: LearningSpace) {
        var updatedSpace = space
        updatedSpace.lastAccessedDate = Date()
        storageService.updateLearningSpace(updatedSpace)

        if let index = spaces.firstIndex(where: { $0.id == space.id }) {
            spaces[index] = updatedSpace
        }
    }
}
