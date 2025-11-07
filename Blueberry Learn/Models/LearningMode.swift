import Foundation

enum LearningMode: String, CaseIterable, Codable, Hashable {
    case standard = "Standard"
    case debate = "Debate Me"
    case mimic = "Mimic"
    case quiz = "Quiz Me"

    var icon: String {
        switch self {
        case .standard:
            return "text.bubble"
        case .debate:
            return "debate_mode"
        case .mimic:
            return "mimic"
        case .quiz:
            return "quiz_me"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "Regular tutoring and Q&A"
        case .debate:
            return "Engage in constructive debate"
        case .mimic:
            return "Chat with a custom character"
        case .quiz:
            return "Test your knowledge with questions"
        }
    }
}

// MARK: - Learning Lens (simplified for POC)
struct LearningLens: Codable {
    let name: String
    let themeDescription: String

    static let availableLenses = [
        LearningLens(name: "Star Wars", themeDescription: "Learn through Star Wars analogies"),
        LearningLens(name: "Minecraft", themeDescription: "Learn through Minecraft building and crafting"),
        LearningLens(name: "Pokemon", themeDescription: "Learn through Pokemon battles and training"),
        LearningLens(name: "Marvel Avengers", themeDescription: "Learn through Marvel superheroes and powers"),
        LearningLens(name: "None", themeDescription: "No thematic lens")
    ]
}
