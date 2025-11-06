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
    let preamble: String?  // New: Intro text before question
    let questionText: String?  // Renamed from 'question' for clarity
    let hint: String?  // New: Optional hint for the question
    let questionType: String?
    let options: [String]?
    let correctAnswer: String?

    // For feedback
    let isCorrect: Bool?
    let userAnswer: String?  // New: What the user answered
    let explanation: String?
    let encouragement: String?  // New: Motivational message

    // For quiz_complete
    let score: String?
    let percentage: Int?
    let summary: String?  // New: Overall summary message
    let strengths: [String]?
    let weaknesses: [String]?
    let improvementPlan: String?
    let closingMessage: String?  // New: Final message/call to action

    enum CodingKeys: String, CodingKey {
        case type
        case topic
        case number
        case total
        case preamble
        case questionText
        case hint
        case questionType
        case options
        case correctAnswer
        case isCorrect
        case userAnswer
        case explanation
        case encouragement
        case score
        case percentage
        case summary
        case strengths
        case weaknesses
        case improvementPlan
        case closingMessage
    }

    // Add backward compatibility for 'question' field
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(QuizResponseType.self, forKey: .type)
        self.topic = try container.decodeIfPresent(String.self, forKey: .topic)
        self.number = try container.decodeIfPresent(Int.self, forKey: .number)
        self.total = try container.decodeIfPresent(Int.self, forKey: .total)
        self.preamble = try container.decodeIfPresent(String.self, forKey: .preamble)

        // Try to decode questionText, fall back to 'question' for backward compatibility
        if let questionText = try container.decodeIfPresent(String.self, forKey: .questionText) {
            self.questionText = questionText
        } else {
            // Try the old key name
            enum LegacyKeys: String, CodingKey {
                case question
            }
            let legacyContainer = try decoder.container(keyedBy: LegacyKeys.self)
            self.questionText = try legacyContainer.decodeIfPresent(String.self, forKey: .question)
        }

        self.hint = try container.decodeIfPresent(String.self, forKey: .hint)
        self.questionType = try container.decodeIfPresent(String.self, forKey: .questionType)
        self.options = try container.decodeIfPresent([String].self, forKey: .options)
        self.correctAnswer = try container.decodeIfPresent(String.self, forKey: .correctAnswer)
        self.isCorrect = try container.decodeIfPresent(Bool.self, forKey: .isCorrect)
        self.userAnswer = try container.decodeIfPresent(String.self, forKey: .userAnswer)
        self.explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        self.encouragement = try container.decodeIfPresent(String.self, forKey: .encouragement)
        self.score = try container.decodeIfPresent(String.self, forKey: .score)
        self.percentage = try container.decodeIfPresent(Int.self, forKey: .percentage)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.strengths = try container.decodeIfPresent([String].self, forKey: .strengths)
        self.weaknesses = try container.decodeIfPresent([String].self, forKey: .weaknesses)
        self.improvementPlan = try container.decodeIfPresent(String.self, forKey: .improvementPlan)
        self.closingMessage = try container.decodeIfPresent(String.self, forKey: .closingMessage)
    }
}

// MARK: - Quiz Response Parser
class QuizResponseParser {
    static func parseJSON(from content: String) -> QuizResponse? {
        // First, try to parse the entire content as JSON (for pure JSON responses)
        if let directData = content.data(using: .utf8),
           let response = try? JSONDecoder().decode(QuizResponse.self, from: directData) {
            return response
        }

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

        // As a last resort, try to find raw JSON by looking for { ... } pattern
        let jsonPattern = "\\{[\\s\\S]*\\}"
        if let regex = try? NSRegularExpression(pattern: jsonPattern, options: []),
           let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
           let jsonRange = Range(match.range, in: content) {
            let jsonString = String(content[jsonRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            if let jsonData = jsonString.data(using: .utf8),
               let response = try? JSONDecoder().decode(QuizResponse.self, from: jsonData) {
                return response
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
