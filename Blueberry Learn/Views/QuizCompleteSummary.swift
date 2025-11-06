import SwiftUI

struct QuizCompleteSummary: View {
    let quizSession: QuizSession

    @State private var showStrengths = true
    @State private var showWeaknesses = true
    @State private var showImprovementPlan = true

    var body: some View {
        VStack(spacing: 20) {
            // Score display
            VStack(spacing: 12) {
                // Trophy or star icon
                Image(systemName: quizSession.percentage ?? 0 >= 75 ? "star.fill" : "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(scoreColor)

                Text("Quiz Complete!")
                    .font(.system(size: 24, weight: .bold))

                if let score = quizSession.score {
                    Text(score)
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(scoreColor)
                }

                if let percentage = quizSession.percentage {
                    Text("\(percentage)%")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(scoreColor.opacity(0.1))
            )

            // Strengths section
            if !quizSession.strengths.isEmpty {
                CollapsibleSection(
                    title: "What You Understand Well",
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    isExpanded: $showStrengths
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(quizSession.strengths, id: \.self) { strength in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.top, 4)

                                Text(strength)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }

            // Weaknesses section
            if !quizSession.weaknesses.isEmpty {
                CollapsibleSection(
                    title: "Areas Needing Work",
                    icon: "exclamationmark.triangle.fill",
                    iconColor: .orange,
                    isExpanded: $showWeaknesses
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(quizSession.weaknesses, id: \.self) { weakness in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)

                                Text(weakness)
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }

            // Improvement plan section
            if let improvementPlan = quizSession.improvementPlan {
                CollapsibleSection(
                    title: "Your Improvement Plan",
                    icon: "book.fill",
                    iconColor: .blue,
                    isExpanded: $showImprovementPlan
                ) {
                    Text(improvementPlan)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }

    private var scoreColor: Color {
        guard let percentage = quizSession.percentage else { return .blue }
        if percentage >= 90 {
            return .green
        } else if percentage >= 75 {
            return .blue
        } else if percentage >= 60 {
            return .orange
        } else {
            return .red
        }
    }
}

struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)

                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Content
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    let session = QuizSession(topic: "Photosynthesis", quizType: .multipleChoice)
    session.completeQuiz(
        score: "3/4",
        percentage: 75,
        strengths: [
            "Strong understanding of photosynthesis pigments",
            "Good grasp of light-dependent reactions"
        ],
        weaknesses: [
            "Need more practice with Calvin cycle steps",
            "Slightly confused about ATP synthesis timing"
        ],
        improvementPlan: "To strengthen your understanding, I recommend: 1) Reviewing the Calvin cycle in detail, focusing on the role of RuBisCO and the regeneration of RuBP. 2) Creating a diagram that shows when ATP and NADPH are produced vs. when they are consumed."
    )

    return ScrollView {
        QuizCompleteSummary(quizSession: session)
            .padding()
    }
}
