import Foundation
import SwiftUI
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var currentMode: LearningMode = .standard
    @Published var currentLens: LearningLens? = nil
    @Published var isShowingModeSelection = false
    @Published var isLoading = false
    @Published var customEntityName = ""
    @Published var showCustomEntityAlert = false
    @Published var streamingMessageContent = ""
    @Published var errorMessage: String?

    // Timer-related properties
    @Published var sessionTimer = SessionTimer()
    @Published var isShowingTimerSelection = false
    @Published var isShowingTimerDetail = false
    @Published var hasShownExpiredMessage = false
    @Published var showNavigationAlert = false

    // Frustration button properties
    @Published var frustrationButtonPressedAtMessageCount: Int?
    @Published var frustrationToastMessage: String?

    // Quiz-related properties
    @Published var quizSession: QuizSession?
    @Published var isShowingQuizTypeSelection = false
    @Published var pendingQuizTopic: String?
    @Published var selectedMultipleChoiceAnswer: String?
    @Published var hasSubmittedCurrentAnswer = false

    // Computed property to check if quiz is active and locked
    var isQuizLocked: Bool {
        return quizSession != nil && !(quizSession?.isComplete ?? false)
    }

    let space: LearningSpace
    var session: ChatSession
    private var isNewSession = false // Track if this is a new unsaved session
    private let storageService = StorageService.shared
    private let anthropicService = AnthropicService()
    private let promptManager = PromptManager.shared
    private var streamingTask: Task<Void, Never>?
    private var timerObserver: AnyCancellable?

    init(space: LearningSpace, sessionId: UUID? = nil) {
        self.space = space

        // Load existing session or create new one (in memory only)
        if let sessionId = sessionId,
           let existingSession = storageService.getSession(sessionId, from: space.id) {
            self.session = existingSession
            self.isNewSession = false
        } else {
            // Create a new session in memory but don't save it yet
            self.session = ChatSession(spaceId: space.id)
            self.isNewSession = true
        }

        loadMessages()
        setupTimerObserver()
    }

    func loadMessages() {
        messages = session.messages
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // If in quiz mode and no quiz session, capture topic and show type selection
        if currentMode == .quiz && quizSession == nil && pendingQuizTopic == nil {
            pendingQuizTopic = inputText
            isShowingQuizTypeSelection = true
            return
        }

        // Cancel any existing streaming task
        streamingTask?.cancel()

        // Check if this is the first user message and a lens is already selected
        let isFirstUserMessage = messages.filter({ $0.role == .user && !$0.isHidden }).isEmpty
        if isFirstUserMessage && currentLens != nil {
            // Send hidden lens activation message before the first user message
            let lensInstructions = promptManager.getLensChangeInstructions(
                newLens: currentLens,
                previousLens: nil
            )

            if !lensInstructions.isEmpty {
                let hiddenLensMessage = ChatMessage(
                    content: lensInstructions,
                    role: .user,
                    spaceId: space.id,
                    activeMode: currentMode,
                    activeLens: currentLens?.name,
                    isHidden: true
                )
                messages.append(hiddenLensMessage)
                session.messages.append(hiddenLensMessage)
            }
        }

        // Add user message
        let userMessage = ChatMessage(
            content: inputText,
            role: .user,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(userMessage)

        // Update session with new message
        session.messages.append(userMessage)
        session.lastMessageDate = Date()
        session.updateTitle() // Update title if this is first message

        // If this is a new unsaved session, save it now
        if isNewSession {
            // Add the session to storage for the first time
            var sessions = storageService.loadSessions(for: space.id)
            sessions.append(session)
            storageService.saveSessions(sessions, for: space.id)
            isNewSession = false
        } else {
            // Update existing session
            storageService.updateSession(session)
        }

        let currentInput = inputText
        inputText = ""
        errorMessage = nil
        streamingMessageContent = ""
        isLoading = true

        // Create a placeholder for the assistant's response
        let assistantMessage = ChatMessage(
            content: "",
            role: .assistant,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(assistantMessage)

        // Add empty assistant message to session
        session.messages.append(assistantMessage)

        // Start streaming response
        streamingTask = Task {
            do {
                print("🟡 [ChatViewModel] Starting message stream...")
                print("🟡 [ChatViewModel] Current mode: \(currentMode)")
                print("🟡 [ChatViewModel] Current lens: \(currentLens?.name ?? "none")")
                print("🟡 [ChatViewModel] Message count: \(messages.count)")

                let stream = try await anthropicService.streamMessage(
                    prompt: currentInput,
                    context: Array(messages.dropLast(2)), // Exclude the user message we just added and empty assistant message
                    space: space,
                    mode: currentMode,
                    customEntityName: currentMode == .mimic ? customEntityName : nil,
                    sessionTimerDescription: sessionTimer.getSessionDescription()
                )

                print("🟢 [ChatViewModel] Stream obtained, starting to receive chunks...")

                var fullResponse = ""
                for try await chunk in stream {
                    fullResponse += chunk
                    await MainActor.run {
                        self.streamingMessageContent = fullResponse
                        // Update the last message with streaming content
                        if let lastIndex = self.messages.indices.last {
                            self.messages[lastIndex].content = fullResponse
                        }
                    }
                }

                // Save the complete message
                await MainActor.run {
                    if let lastIndex = self.messages.indices.last {
                        // Handle quiz mode specially - parse JSON and clear content
                        if self.currentMode == .quiz {
                            if let quizResponse = self.parseQuizResponse(from: fullResponse) {
                                self.messages[lastIndex].content = "" // Clear raw JSON from display
                                self.messages[lastIndex].quizData = quizResponse
                                self.handleQuizResponse(quizResponse)

                                // Update session with quiz data
                                self.session.messages[lastIndex].content = "" // Don't store JSON
                                self.session.messages[lastIndex].quizData = quizResponse
                            } else {
                                // Failed to parse JSON, show error to user
                                self.messages[lastIndex].content = "⚠️ Quiz Error: Invalid response format. Please try again."
                                print("🔴 [ChatViewModel] Failed to parse quiz JSON: \(fullResponse)")
                            }
                        } else {
                            // Normal mode: just store the content
                            self.messages[lastIndex].content = fullResponse

                            // Update session with assistant's response
                            self.session.messages[lastIndex].content = fullResponse
                        }

                        self.session.lastMessageDate = Date()
                        self.storageService.updateSession(self.session)
                    }
                    self.isLoading = false
                    self.streamingMessageContent = ""
                }
            } catch {
                print("🔴 [ChatViewModel] Error in sendMessage:")
                print("🔴 [ChatViewModel] Error: \(error)")
                print("🔴 [ChatViewModel] Error type: \(type(of: error))")
                print("🔴 [ChatViewModel] Error localized: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("🔴 [ChatViewModel] NSError domain: \(nsError.domain)")
                    print("🔴 [ChatViewModel] NSError code: \(nsError.code)")
                    print("🔴 [ChatViewModel] NSError userInfo: \(nsError.userInfo)")
                }

                await MainActor.run {
                    // Create more user-friendly error messages
                    var errorMessage = "Failed to get response"

                    if (error as NSError).code == -1009 {
                        errorMessage = "No internet connection. Please check your network."
                    } else if error.localizedDescription.contains("401") || error.localizedDescription.contains("authentication") {
                        errorMessage = "Invalid API key. Please check your API key in APIConfiguration.swift"
                    } else if error.localizedDescription.contains("429") {
                        errorMessage = "Rate limit exceeded. Please wait a moment and try again."
                    } else {
                        errorMessage += ": \(error.localizedDescription)"
                    }

                    self.errorMessage = errorMessage
                    self.isLoading = false
                    // Remove the empty assistant message on error
                    if self.messages.last?.content.isEmpty == true {
                        self.messages.removeLast()
                    }
                }
            }
        }
    }

    func switchMode(_ mode: LearningMode) {
        // Toggle: if already in this mode, switch back to standard
        if currentMode == mode {
            currentMode = .standard
            if mode == .quiz {
                exitQuizMode()
            }
        } else {
            currentMode = mode
            if mode == .mimic {
                showCustomEntityAlert = true
            }
        }
    }

    func applyLens(_ lens: LearningLens?) {
        // Check if lens is actually changing
        let previousLens = currentLens
        let isChanging = (previousLens?.name != lens?.name)

        // Update current lens
        currentLens = lens

        // If lens is changing and we have messages in the conversation, send a hidden message
        if isChanging && !messages.isEmpty {
            // Get lens change instructions from PromptManager
            let lensInstructions = promptManager.getLensChangeInstructions(
                newLens: lens,
                previousLens: previousLens
            )

            // Only send hidden message if there are instructions (lens actually changed)
            if !lensInstructions.isEmpty {
                // Create a hidden user message with the lens change instructions
                let hiddenMessage = ChatMessage(
                    content: lensInstructions,
                    role: .user,
                    spaceId: space.id,
                    activeMode: currentMode,
                    activeLens: lens?.name,
                    isHidden: true
                )

                // Append to both messages and session
                messages.append(hiddenMessage)
                session.messages.append(hiddenMessage)

                // Update session
                session.lastMessageDate = Date()
                if !isNewSession {
                    storageService.updateSession(session)
                }
            }
        }
    }

    func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        isLoading = false
    }

    // MARK: - Timer Methods

    private func setupTimerObserver() {
        // Observe timer expiration to send summary message
        timerObserver = sessionTimer.$hasExpired
            .sink { [weak self] hasExpired in
                guard let self = self,
                      hasExpired,
                      !self.hasShownExpiredMessage else { return }

                self.hasShownExpiredMessage = true
                // The next message sent will include timer expiration info
                // via sessionTimer.getSessionDescription()
            }
    }

    func startTimer(minutes: Int) {
        sessionTimer.start(minutes: minutes)
        hasShownExpiredMessage = false

        // Add automatic acknowledgment message from the assistant
        let durationText = minutes >= 60 ? "\(minutes / 60) hour\(minutes >= 120 ? "s" : "")" : "\(minutes) minutes"
        let acknowledgmentText = "Got it! I see we have \(durationText) for our session today. This will help me pace our conversation and keep us on track for the time you have available. What would you like to focus on?"

        let acknowledgmentMessage = ChatMessage(
            content: acknowledgmentText,
            role: .assistant,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )

        messages.append(acknowledgmentMessage)
        session.messages.append(acknowledgmentMessage)
        session.lastMessageDate = Date()

        // If this is a new unsaved session, save it now
        if isNewSession {
            var sessions = storageService.loadSessions(for: space.id)
            sessions.append(session)
            storageService.saveSessions(sessions, for: space.id)
            isNewSession = false
        } else {
            storageService.updateSession(session)
        }
    }

    func endTimer() {
        sessionTimer.stop()
        hasShownExpiredMessage = false
    }

    // MARK: - Frustration Button Methods

    var isFrustrationButtonDisabled: Bool {
        let currentUserMessageCount = messages.filter { $0.role == .user }.count

        // Disable if no messages have been sent yet
        if currentUserMessageCount == 0 {
            return true
        }

        // Check cooldown period
        guard let pressedAtCount = frustrationButtonPressedAtMessageCount else {
            return false // Button is enabled if never pressed
        }

        return currentUserMessageCount < pressedAtCount + 3
    }

    func handleFrustrationButton() {
        // Check cooldown based on message count
        if isFrustrationButtonDisabled {
            return
        }

        // Trigger haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Show toast message
        frustrationToastMessage = "Feeling frustrated..."

        // Auto-dismiss toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.frustrationToastMessage = nil
        }

        // Set cooldown based on current user message count
        let currentUserMessageCount = messages.filter { $0.role == .user }.count
        frustrationButtonPressedAtMessageCount = currentUserMessageCount

        // Send the frustration signal via a special message
        sendFrustrationSignal()
    }

    private func sendFrustrationSignal() {
        // Cancel any existing streaming task
        streamingTask?.cancel()

        errorMessage = nil
        streamingMessageContent = ""
        isLoading = true

        // Get frustration instructions from PromptManager
        let frustrationInstructions = promptManager.getFrustrationInstructions()

        // Create a hidden user message with the frustration instructions
        let hiddenUserMessage = ChatMessage(
            content: frustrationInstructions,
            role: .user,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name,
            isHidden: true
        )
        messages.append(hiddenUserMessage)
        session.messages.append(hiddenUserMessage)

        // Create a placeholder for the assistant's response
        let assistantMessage = ChatMessage(
            content: "",
            role: .assistant,
            spaceId: space.id,
            activeMode: currentMode,
            activeLens: currentLens?.name
        )
        messages.append(assistantMessage)

        // Add empty assistant message to session
        session.messages.append(assistantMessage)

        // Update last message date
        session.lastMessageDate = Date()

        // If this is a new unsaved session, save it now
        if isNewSession {
            var sessions = storageService.loadSessions(for: space.id)
            sessions.append(session)
            storageService.saveSessions(sessions, for: space.id)
            isNewSession = false
        } else {
            storageService.updateSession(session)
        }

        // Start streaming response with frustration context
        streamingTask = Task {
            do {
                print("🟡 [ChatViewModel] Starting frustration signal stream...")

                // Send a generic continuation prompt
                let stream = try await anthropicService.streamMessage(
                    prompt: "Please respond to my situation.",
                    context: Array(messages.dropLast(1)), // Exclude the empty assistant message
                    space: space,
                    mode: currentMode,
                    customEntityName: currentMode == .mimic ? customEntityName : nil,
                    sessionTimerDescription: sessionTimer.getSessionDescription()
                )

                print("🟢 [ChatViewModel] Frustration signal stream obtained...")

                var fullResponse = ""
                for try await chunk in stream {
                    fullResponse += chunk
                    await MainActor.run {
                        self.streamingMessageContent = fullResponse
                        // Update the last message with streaming content
                        if let lastIndex = self.messages.indices.last {
                            self.messages[lastIndex].content = fullResponse
                        }
                    }
                }

                // Save the complete message
                await MainActor.run {
                    if let lastIndex = self.messages.indices.last {
                        self.messages[lastIndex].content = fullResponse

                        // Update session with assistant's response
                        self.session.messages[lastIndex].content = fullResponse
                        self.session.lastMessageDate = Date()
                        self.storageService.updateSession(self.session)
                    }
                    self.isLoading = false
                    self.streamingMessageContent = ""
                }
            } catch {
                print("🔴 [ChatViewModel] Error in sendFrustrationSignal:")
                print("🔴 [ChatViewModel] Error: \(error)")
                print("🔴 [ChatViewModel] Error type: \(type(of: error))")
                print("🔴 [ChatViewModel] Error localized: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("🔴 [ChatViewModel] NSError domain: \(nsError.domain)")
                    print("🔴 [ChatViewModel] NSError code: \(nsError.code)")
                    print("🔴 [ChatViewModel] NSError userInfo: \(nsError.userInfo)")
                }

                await MainActor.run {
                    // Create more user-friendly error messages
                    var errorMessage = "Failed to get response"

                    if (error as NSError).code == -1009 {
                        errorMessage = "No internet connection. Please check your network."
                    } else if error.localizedDescription.contains("401") || error.localizedDescription.contains("authentication") {
                        errorMessage = "Invalid API key. Please check your API key in APIConfiguration.swift"
                    } else if error.localizedDescription.contains("429") {
                        errorMessage = "Rate limit exceeded. Please wait a moment and try again."
                    } else {
                        errorMessage += ": \(error.localizedDescription)"
                    }

                    self.errorMessage = errorMessage
                    self.isLoading = false
                    // Remove the empty assistant message on error
                    if self.messages.last?.content.isEmpty == true {
                        self.messages.removeLast()
                    }
                    // Also remove the hidden user message on error
                    if let secondToLast = self.messages.dropLast().last, secondToLast.isHidden {
                        self.messages.removeLast()
                    }
                }
            }
        }
    }

    // MARK: - Quiz Methods

    func selectQuizType(_ type: QuizType) {
        guard let topic = pendingQuizTopic else { return }

        // Create new quiz session
        quizSession = QuizSession(topic: topic, quizType: type)
        isShowingQuizTypeSelection = false
        pendingQuizTopic = nil

        // Send message to start quiz
        inputText = "Let's start a \(type.displayName) quiz on \(topic)."
        sendMessage()
    }

    func submitQuizAnswer(_ answer: String) {
        guard quizSession != nil else { return }

        hasSubmittedCurrentAnswer = true
        inputText = answer
        sendMessage()

        // Reset selection after sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedMultipleChoiceAnswer = nil
        }
    }

    func exitQuizMode() {
        quizSession = nil
        selectedMultipleChoiceAnswer = nil
        hasSubmittedCurrentAnswer = false
        pendingQuizTopic = nil
        currentMode = .standard
    }

    private func parseQuizResponse(from content: String) -> QuizResponse? {
        return QuizResponseParser.parseJSON(from: content)
    }

    private func handleQuizResponse(_ quizResponse: QuizResponse) {
        guard let session = quizSession else { return }

        switch quizResponse.type {
        case .quizStart:
            // Quiz is starting - no action needed, session already created
            break

        case .question:
            // New question received
            if let number = quizResponse.number,
               let total = quizResponse.total,
               let question = quizResponse.questionText,  // Changed from .question
               let questionTypeString = quizResponse.questionType,
               let questionType = QuizType(rawValue: questionTypeString) {

                let quizQuestion = QuizQuestion(
                    number: number,
                    total: total,
                    question: question,
                    questionType: questionType,
                    options: quizResponse.options,
                    correctAnswer: quizResponse.correctAnswer
                )

                session.addQuestion(quizQuestion)
                hasSubmittedCurrentAnswer = false
            }

        case .feedback:
            // Feedback for current question
            if let isCorrect = quizResponse.isCorrect,
               let explanation = quizResponse.explanation,
               let currentQuestion = session.currentQuestion {

                session.updateCurrentQuestion(
                    userAnswer: currentQuestion.userAnswer ?? "",
                    isCorrect: isCorrect,
                    feedback: explanation
                )

                // Move to next question after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    session.moveToNextQuestion()
                }
            }

        case .quizComplete:
            // Quiz is complete
            if let score = quizResponse.score,
               let percentage = quizResponse.percentage,
               let strengths = quizResponse.strengths,
               let weaknesses = quizResponse.weaknesses,
               let improvementPlan = quizResponse.improvementPlan {

                session.completeQuiz(
                    score: score,
                    percentage: percentage,
                    strengths: strengths,
                    weaknesses: weaknesses,
                    improvementPlan: improvementPlan
                )
            }
        }
    }

    deinit {
        streamingTask?.cancel()
        timerObserver?.cancel()
    }
}
