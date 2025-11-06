import Foundation
import Combine

/// Manages the timer state for timed learning sessions
class SessionTimer: ObservableObject {
    @Published var duration: TimeInterval = 0  // Total duration in seconds
    @Published var startTime: Date?            // When the timer was started
    @Published var isActive: Bool = false      // Whether timer is currently running
    @Published var hasExpired: Bool = false    // Whether timer has reached its duration

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    /// Computed property for elapsed time in seconds
    var elapsedTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    /// Computed property for remaining time in seconds
    var timeRemaining: TimeInterval {
        max(0, duration - elapsedTime)
    }

    /// Progress as a value between 0 and 1
    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, elapsedTime / duration)
    }

    /// Formatted string for elapsed time
    var elapsedTimeString: String {
        formatTime(elapsedTime)
    }

    /// Formatted string for total duration
    var durationString: String {
        formatTime(duration)
    }

    /// Formatted string for remaining time
    var remainingTimeString: String {
        formatTime(timeRemaining)
    }

    /// Start a new timer session with specified duration in minutes
    func start(minutes: Int) {
        // Reset any existing timer
        stop()

        // Set up new timer
        duration = TimeInterval(minutes * 60)
        startTime = Date()
        isActive = true
        hasExpired = false

        // Start a timer that updates every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    /// Pause the current timer
    func pause() {
        timer?.invalidate()
        timer = nil
        isActive = false
    }

    /// Resume a paused timer
    func resume() {
        guard startTime != nil, !isActive else { return }

        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    /// Stop and reset the timer
    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
        duration = 0
        isActive = false
        hasExpired = false
    }

    /// Called every second to update timer state
    private func updateTimer() {
        // Check if timer has expired
        if timeRemaining <= 0 && !hasExpired {
            hasExpired = true
            objectWillChange.send()

            // Don't stop the timer - let it continue counting
            // This allows tracking of overtime
        } else {
            // Just trigger UI update
            objectWillChange.send()
        }
    }

    /// Format time interval as "X min" or "X hr Y min"
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            if remainingMinutes > 0 {
                return "\(hours) hr \(remainingMinutes) min"
            } else {
                return "\(hours) hr"
            }
        } else {
            return "\(minutes) min"
        }
    }

    /// Get a description of the session duration for the AI
    func getSessionDescription() -> String? {
        guard isActive else { return nil }

        let durationMinutes = Int(duration / 60)
        let elapsedMinutes = Int(elapsedTime / 60)
        let remainingMinutes = Int(timeRemaining / 60)

        if hasExpired {
            return "The user requested a \(durationMinutes)-minute session which has now expired (running \(elapsedMinutes - durationMinutes) minutes over). Please begin wrapping up the session with a summary of what was covered."
        } else if remainingMinutes <= 5 && durationMinutes > 10 {
            return "The user requested a \(durationMinutes)-minute session. There are \(remainingMinutes) minutes remaining. Consider starting to wrap up key points."
        } else {
            return "The user requested a \(durationMinutes)-minute session. \(elapsedMinutes) minutes have elapsed with \(remainingMinutes) minutes remaining. Pace the lesson accordingly."
        }
    }

    deinit {
        timer?.invalidate()
    }
}