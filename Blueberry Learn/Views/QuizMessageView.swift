import SwiftUI

// Main router view for quiz messages
struct QuizMessageView: View {
    let quizData: QuizResponse
    let message: ChatMessage
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        switch quizData.type {
        case .question:
            QuizQuestionView(quizData: quizData, viewModel: viewModel)
        case .feedback:
            QuizFeedbackView(quizData: quizData)
        case .quizComplete:
            QuizCompleteView(quizData: quizData)
        case .quizStart:
            // Quiz start doesn't need special UI
            EmptyView()
        }
    }
}

// Display a quiz question
struct QuizQuestionView: View {
    let quizData: QuizResponse
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress indicator
            if let number = quizData.number, let total = quizData.total {
                HStack {
                    Text("Question \(number) of \(total)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }

            // Preamble if present
            if let preamble = quizData.preamble, !preamble.isEmpty {
                Text(preamble)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }

            // Question text
            if let questionText = quizData.questionText {
                Text(questionText)
                    .font(.system(size: 17))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }

            // Hint if present
            if let hint = quizData.hint, !hint.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 12))
                    Text(hint)
                        .font(.system(size: 14))
                }
                .foregroundColor(.blue)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// Display feedback after an answer
struct QuizFeedbackView: View {
    let quizData: QuizResponse

    private var feedbackColor: Color {
        return (quizData.isCorrect ?? false) ? .green : .orange
    }

    private var feedbackIcon: String {
        return (quizData.isCorrect ?? false) ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Correct/Incorrect indicator
            HStack {
                Image(systemName: feedbackIcon)
                    .font(.system(size: 20))
                Text((quizData.isCorrect ?? false) ? "Correct!" : "Not quite right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(feedbackColor)

            // User's answer if present
            if let userAnswer = quizData.userAnswer {
                HStack(spacing: 6) {
                    Text("Your answer:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(userAnswer)
                        .font(.system(size: 14, weight: .medium))
                }
            }

            // Correct answer if user was wrong
            if !(quizData.isCorrect ?? true), let correctAnswer = quizData.correctAnswer {
                HStack(spacing: 6) {
                    Text("Correct answer:")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text(correctAnswer)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }

            // Explanation
            if let explanation = quizData.explanation {
                Text(explanation)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }

            // Encouragement
            if let encouragement = quizData.encouragement {
                Text(encouragement)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(feedbackColor.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(feedbackColor.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// Display the final quiz summary
struct QuizCompleteView: View {
    let quizData: QuizResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with score
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blueberryOrange)

                if let score = quizData.score {
                    Text(score)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }

                if let percentage = quizData.percentage {
                    Text("\(percentage)%")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                }

                if let summary = quizData.summary {
                    Text(summary)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            Divider()

            // Strengths
            if let strengths = quizData.strengths, !strengths.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.green)
                        Text("Strengths")
                            .font(.system(size: 16, weight: .semibold))
                    }

                    ForEach(strengths, id: \.self) { strength in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(strength)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.primary)
                    }
                }
            }

            // Weaknesses
            if let weaknesses = quizData.weaknesses, !weaknesses.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Areas for Improvement")
                            .font(.system(size: 16, weight: .semibold))
                    }

                    ForEach(weaknesses, id: \.self) { weakness in
                        HStack(alignment: .top) {
                            Text("•")
                            Text(weakness)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.primary)
                    }
                }
            }

            // Improvement Plan
            if let plan = quizData.improvementPlan {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.blue)
                        Text("Next Steps")
                            .font(.system(size: 16, weight: .semibold))
                    }

                    Text(plan)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }

            // Closing message
            if let closingMessage = quizData.closingMessage {
                Text(closingMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}