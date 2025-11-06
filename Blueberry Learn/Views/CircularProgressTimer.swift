import SwiftUI

struct CircularProgressTimer: View {
    @ObservedObject var timer: SessionTimer
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                .frame(width: 28, height: 28)

            // Progress circle
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    Color(red: 0.76, green: 0.44, blue: 0.35),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 28, height: 28)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timer.progress)

            // Clock icon or check mark
            Image(systemName: timer.hasExpired ? "checkmark" : "clock.fill")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.76, green: 0.44, blue: 0.35))
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Preview helper to show the timer in action
struct CircularProgressTimer_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            // Active timer at 25%
            CircularProgressTimer(timer: {
                let t = SessionTimer()
                t.start(minutes: 30)
                return t
            }())

            // Active timer at 75%
            CircularProgressTimer(timer: {
                let t = SessionTimer()
                t.start(minutes: 30)
                // Simulate progress
                return t
            }())

            // Expired timer
            CircularProgressTimer(timer: {
                let t = SessionTimer()
                t.start(minutes: 1)
                // Simulate expired
                return t
            }())
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}