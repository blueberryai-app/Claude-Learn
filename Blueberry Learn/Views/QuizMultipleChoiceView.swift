import SwiftUI

struct QuizMultipleChoiceView: View {
    @ObservedObject var viewModel: ChatViewModel
    let question: QuizQuestion

    var body: some View {
        VStack(spacing: 12) {
            // Progress indicator
            HStack {
                Text("Question \(question.number) of \(question.total)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)

            // Answer options
            if let options = question.options {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        MultipleChoiceButton(
                            option: option,
                            isSelected: viewModel.selectedMultipleChoiceAnswer == option,
                            isSubmitted: viewModel.hasSubmittedCurrentAnswer,
                            // Only reveal correct answer after submission
                            isCorrect: viewModel.hasSubmittedCurrentAnswer ? option.hasPrefix(question.correctAnswer ?? "") : false,
                            action: {
                                if !viewModel.hasSubmittedCurrentAnswer {
                                    viewModel.selectedMultipleChoiceAnswer = option
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }

            // Submit button
            if let selectedAnswer = viewModel.selectedMultipleChoiceAnswer,
               !viewModel.hasSubmittedCurrentAnswer {
                Button(action: {
                    viewModel.submitQuizAnswer(selectedAnswer)
                }) {
                    Text("Submit Answer")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blueberryOrange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 12)
    }
}

struct MultipleChoiceButton: View {
    let option: String
    let isSelected: Bool
    let isSubmitted: Bool
    let isCorrect: Bool
    let action: () -> Void

    private var backgroundColor: Color {
        if isSubmitted {
            if isSelected {
                return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
            } else if isCorrect {
                return Color.green.opacity(0.2)
            }
            return Color(.systemGray6)
        }
        return isSelected ? Color.blueberryOrange.opacity(0.15) : Color(.systemGray6)
    }

    private var borderColor: Color {
        if isSubmitted {
            if isSelected {
                return isCorrect ? Color.green : Color.red
            } else if isCorrect {
                return Color.green
            }
            return Color.clear
        }
        return isSelected ? Color.blueberryOrange : Color.clear
    }

    private var iconName: String? {
        if isSubmitted {
            if isSelected {
                return isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
            } else if isCorrect {
                return "checkmark.circle.fill"
            }
        }
        return nil
    }

    private var iconColor: Color {
        if isSubmitted {
            if isSelected {
                return isCorrect ? Color.green : Color.red
            } else if isCorrect {
                return Color.green
            }
        }
        return .primary
    }

    var body: some View {
        Button(action: {
            if !isSubmitted {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 12) {
                // Option text
                Text(option)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Icon (shown after submission)
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSubmitted)
    }
}

#Preview {
    let viewModel = ChatViewModel(space: LearningSpace.mockSpaces.first!)
    let question = QuizQuestion(
        number: 1,
        total: 4,
        question: "What is the primary pigment in photosynthesis?",
        questionType: .multipleChoice,
        options: ["A) Carotene", "B) Chlorophyll", "C) Xanthophyll", "D) Anthocyanin"],
        correctAnswer: "B"
    )

    return QuizMultipleChoiceView(viewModel: viewModel, question: question)
        .padding()
}
