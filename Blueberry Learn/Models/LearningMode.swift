import Foundation

enum LearningMode: String, CaseIterable, Codable, Hashable {
    case standard = "Standard"
    case writing = "Writing Mode"
    case debate = "Debate Me"
    case mimic = "Mimic"
    case quiz = "Quiz Me"

    var icon: String {
        switch self {
        case .standard:
            return "text.bubble"
        case .writing:
            return "pencil.and.outline"
        case .debate:
            return "person.2.fill"
        case .mimic:
            return "theatermasks"
        case .quiz:
            return "questionmark.circle"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "Regular tutoring and Q&A"
        case .writing:
            return "Get help with writing and composition"
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
        LearningLens(name: "Sports", themeDescription: "Sports metaphors and examples"),
        LearningLens(name: "History", themeDescription: "Historical context and examples"),
        LearningLens(name: "Pop Culture", themeDescription: "Modern references and memes"),
        LearningLens(name: "None", themeDescription: "No thematic lens")
    ]
}
