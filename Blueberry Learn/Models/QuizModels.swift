import Foundation
import Combine

// MARK: - Quiz Type Enum
enum QuizType: String, Codable {
    case multipleChoice = "multiple_choice"
    case extendedResponse = "extended_response"

    var displayName: String {
        switch self {
        case .multipleChoice:
            return "Multiple Choice"
        case .extendedResponse:
            return "Extended Response"
        }
    }

    var icon: String {
        switch self {
        case .multipleChoice:
            return "list.bullet.circle.fill"
        case .extendedResponse:
            return "text.alignleft"
        }
    }

    var description: String {
        switch self {
        case .multipleChoice:
            return "Quick questions with 4 options"
        case .extendedResponse:
            return "Write detailed answers to test deep understanding"
        }
    }
}

// MARK: - Quiz Response Type
enum QuizResponseType: String, Codable {
    case quizStart = "quiz_start"
    case question = "question"
    case feedback = "feedback"
    case quizComplete = "quiz_complete"
}

// MARK: - Quiz Question
struct QuizQuestion: Codable, Identifiable {
    let id: UUID
    let number: Int
    let total: Int
    let question: String
    let questionType: QuizType
    let options: [String]? // For multiple choice
    let correctAnswer: String? // For multiple choice (e.g., "B")
    var userAnswer: String?
    var isCorrect: Bool?
    var feedback: String?

    init(
        id: UUID = UUID(),
        number: Int,
        total: Int,
        question: String,
        questionType: QuizType,
        options: [String]? = nil,
        correctAnswer: String? = nil,
        userAnswer: String? = nil,
        isCorrect: Bool? = nil,
        feedback: String? = nil
    ) {
        self.id = id
        self.number = number
        self.total = total
        self.question = question
        self.questionType = questionType
        self.options = options
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
        self.feedback = feedback
    }
}

// MARK: - Quiz Session
class QuizSession: ObservableObject {
    @Published var topic: String
    @Published var quizType: QuizType
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var isComplete: Bool = false
    @Published var score: String?
    @Published var percentage: Int?
    @Published var strengths: [String] = []
    @Published var weaknesses: [String] = []
    @Published var improvementPlan: String?

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var isAwaitingAnswer: Bool {
        guard let current = currentQuestion else { return false }
        return current.userAnswer == nil
    }

    init(topic: String, quizType: QuizType) {
        self.topic = topic
        self.quizType = quizType
    }

    func addQuestion(_ question: QuizQuestion) {
        questions.append(question)
    }

    func updateCurrentQuestion(userAnswer: String, isCorrect: Bool?, feedback: String?) {
        guard currentQuestionIndex < questions.count else { return }
        questions[currentQuestionIndex].userAnswer = userAnswer
        questions[currentQuestionIndex].isCorrect = isCorrect
        questions[currentQuestionIndex].feedback = feedback
    }

    func moveToNextQuestion() {
        currentQuestionIndex += 1
    }

    func completeQuiz(score: String, percentage: Int, strengths: [String], weaknesses: [String], improvementPlan: String) {
        self.score = score
        self.percentage = percentage
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.improvementPlan = improvementPlan
        self.isComplete = true
    }
}

// MARK: - Quiz Response (Parsed from JSON)
struct QuizResponse: Codable, Hashable, Equatable {
    let type: QuizResponseType

    // For quiz_start
    let topic: String?

    // For question
    let number: Int?
    let total: Int?
    let question: String?
    let questionType: String?
    let options: [String]?
    let correctAnswer: String?

    // For feedback
    let isCorrect: Bool?
    let explanation: String?

    // For quiz_complete
    let score: String?
    let percentage: Int?
    let strengths: [String]?
    let weaknesses: [String]?
    let improvementPlan: String?

    enum CodingKeys: String, CodingKey {
        case type
        case topic
        case number
        case total
        case question
        case questionType
        case options
        case correctAnswer
        case isCorrect
        case explanation
        case score
        case percentage
        case strengths
        case weaknesses
        case improvementPlan
    }
}

// MARK: - Quiz Response Parser
class QuizResponseParser {
    static func parseJSON(from content: String) -> QuizResponse? {
        // Look for JSON in markdown code blocks
        let patterns = [
            "```json\\s*([\\s\\S]*?)```",  // ```json ... ```
            "```\\s*([\\s\\S]*?)```"        // ``` ... ```
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
               let jsonRange = Range(match.range(at: 1), in: content) {
                let jsonString = String(content[jsonRange]).trimmingCharacters(in: .whitespacesAndNewlines)

                if let jsonData = jsonString.data(using: .utf8),
                   let response = try? JSONDecoder().decode(QuizResponse.self, from: jsonData) {
                    return response
                }
            }
        }

        return nil
    }

    static func extractPlainText(from content: String) -> String {
        // Remove JSON code blocks to get just the conversational text
        let pattern = "```json?\\s*[\\s\\S]*?```"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(content.startIndex..., in: content)
            let cleanedContent = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
            return cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return content
    }
}
