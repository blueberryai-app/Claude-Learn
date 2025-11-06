import SwiftUI

struct TimerDetailSheet: View {
    @ObservedObject var timer: SessionTimer
    @Binding var isPresented: Bool
    let onEndSession: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Close handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            // Timer status
            VStack(spacing: 16) {
                // Large circular progress
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 8)
                        .frame(width: 120, height: 120)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: timer.progress)
                        .stroke(
                            timer.hasExpired ? Color.orange : Color.blue,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: timer.progress)

                    // Time display
                    VStack(spacing: 4) {
                        Text(timer.elapsedTimeString)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("of \(timer.durationString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Status text
                if timer.hasExpired {
                    Label("Session time expired", systemImage: "clock.badge.checkmark")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                } else {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("\(timer.remainingTimeString) remaining")
                            .font(.subheadline)
                    }
                }

                // Progress percentage
                Text("\(Int(timer.progress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Actions
            VStack(spacing: 12) {
                if !timer.hasExpired {
                    Button(action: {
                        onEndSession()
                        isPresented = false
                    }) {
                        Label("End Session Early", systemImage: "stop.circle")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: {
                    isPresented = false
                }) {
                    Text(timer.hasExpired ? "Continue Learning" : "Back to Chat")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)

            // Info text
            if timer.hasExpired {
                Text("Your session has ended, but you can continue chatting as long as you'd like!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
        .presentationDetents([.height(timer.hasExpired ? 380 : 400)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    TimerDetailSheet(
        timer: {
            let timer = SessionTimer()
            timer.start(minutes: 30)
            return timer
        }(),
        isPresented: .constant(true),
        onEndSession: {}
    )
}