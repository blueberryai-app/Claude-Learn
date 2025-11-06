import SwiftUI

struct QuizTypeSelectionSheet: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.claudeOrange)

                    Text("Choose Quiz Type")
                        .font(.system(size: 28, weight: .bold))

                    if let topic = viewModel.pendingQuizTopic {
                        Text("Topic: \(topic)")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)

                // Quiz type options
                VStack(spacing: 16) {
                    QuizTypeOptionButton(
                        type: .multipleChoice,
                        action: {
                            viewModel.selectQuizType(.multipleChoice)
                            dismiss()
                        }
                    )

                    QuizTypeOptionButton(
                        type: .extendedResponse,
                        action: {
                            viewModel.selectQuizType(.extendedResponse)
                            dismiss()
                        }
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct QuizTypeOptionButton: View {
    let type: QuizType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.claudeOrange)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.claudeOrange.opacity(0.1))
                    )

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(type.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.claudeOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuizTypeSelectionSheet(viewModel: ChatViewModel(space: LearningSpace.mockSpaces.first!))
}
