import Foundation

struct LearningSpace: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String // SF Symbol name
    var systemPrompt: String
    let createdDate: Date
    var lastAccessedDate: Date

    init(name: String, icon: String, systemPrompt: String = "") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.systemPrompt = systemPrompt
        self.createdDate = Date()
        self.lastAccessedDate = Date()
    }
}

// MARK: - Mock Data
extension LearningSpace {
    static var mockSpaces: [LearningSpace] {
        [
            LearningSpace(
                name: "Physics - Mech",
                icon: "physics_space_icon",
                systemPrompt: "You are a physics tutor specializing in mechanics. Help students understand forces, motion, energy, and momentum."
            ),
            LearningSpace(
                name: "Electrical Eng",
                icon: "electrical_eng_space_icon",
                systemPrompt: "You are an electrical engineering tutor. Help students understand circuits, signals, and electrical systems."
            ),
            LearningSpace(
                name: "Literature",
                icon: "literature_space_icon",
                systemPrompt: "You are a literature tutor. Help students analyze texts, understand themes, and improve their literary analysis skills."
            ),
            LearningSpace(
                name: "Writing",
                icon: "writing_space_icon",
                systemPrompt: "You are a writing coach. Help students improve their writing skills, from structure to style."
            ),
            LearningSpace(
                name: "Biology",
                icon: "biology_space_icon",
                systemPrompt: "You are a biology tutor. Help students understand life sciences, from cells to ecosystems."
            )
        ]
    }
}
