import SwiftUI
import MarkdownUI

struct ChatView: View {
    let sessionId: UUID?
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(sessionId: UUID? = nil) {
        self.sessionId = sessionId
        self._viewModel = StateObject(wrappedValue: ChatViewModel(sessionId: sessionId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Error banner if present
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.primary)
                    Spacer()
                    Button("Dismiss") {
                        viewModel.errorMessage = nil
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.messages.isEmpty {
                            EmptyStateView(icon: "book")
                        } else {
                            ForEach(viewModel.messages.filter { !$0.isHidden }) { message in
                                VStack(spacing: 12) {
                                    MessageBubble(
                                        message: message,
                                        isStreaming: viewModel.isLoading && message.id == viewModel.messages.last?.id,
                                        viewModel: viewModel
                                    )
                                    .id(message.id)

                                    // Show quiz completion summary if present
                                    if let quizData = message.quizData,
                                       quizData.type == .quizComplete,
                                       let session = viewModel.quizSession,
                                       session.isComplete {
                                        QuizCompleteSummary(quizSession: session)
                                            .padding(.horizontal)
                                    }

                                    // Show multiple choice options after quiz question
                                    if let quizData = message.quizData,
                                       quizData.type == .question,
                                       let session = viewModel.quizSession,
                                       let currentQuestion = session.currentQuestion,
                                       currentQuestion.questionType == .multipleChoice,
                                       session.isAwaitingAnswer,
                                       message.id == viewModel.messages.last?.id {
                                        QuizMultipleChoiceView(viewModel: viewModel, question: currentQuestion)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture {
                    isInputFocused = false
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input toolbar
            VStack(spacing: 12) {
                Divider()

                VStack(spacing: 12) {
                    // Input field - hide when in multiple choice quiz mode
                    if viewModel.quizSession?.quizType != .multipleChoice ||
                       viewModel.quizSession?.isComplete == true {
                        HStack(spacing: 8) {
                            TextField("Ask a question or describe what you want to learn", text: $viewModel.inputText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .focused($isInputFocused)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                                .onSubmit {
                                    viewModel.sendMessage()
                                }

                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                viewModel.sendMessage()
                            }) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background((viewModel.inputText.isEmpty || viewModel.isLoading) ? Color.gray : Color.claudeOrange)
                                    .clipShape(Circle())
                            }
                            .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                        }
                    }

                    // Mode selector buttons
                    HStack(spacing: 10) {
                        // Plus button to open full mode selection
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            viewModel.isShowingModeSelection.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(viewModel.isQuizLocked ? .gray : .primary)
                                .frame(width: 32, height: 32)
                        }
                        .disabled(viewModel.isQuizLocked)

                        // Debate Me
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.switchMode(.debate)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image("debate_mode")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.currentMode == .debate ? .blue : (viewModel.isQuizLocked ? .gray : .primary))

                                if viewModel.currentMode == .debate {
                                    Text("Debate Me")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentMode == .debate ? Color.blue.opacity(0.1) : Color.clear)
                            )
                        }
                        .disabled(viewModel.isQuizLocked)
                        .opacity(viewModel.isQuizLocked ? 0.5 : 1.0)

                        // Mimic Mode
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.switchMode(.mimic)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image("mimic")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.currentMode == .mimic ? .blue : (viewModel.isQuizLocked ? .gray : .primary))

                                if viewModel.currentMode == .mimic {
                                    Text("Mimic")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentMode == .mimic ? Color.blue.opacity(0.1) : Color.clear)
                            )
                        }
                        .disabled(viewModel.isQuizLocked)
                        .opacity(viewModel.isQuizLocked ? 0.5 : 1.0)

                        // Quiz Me
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.switchMode(.quiz)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image("quiz_me")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.currentMode == .quiz ? .blue : .primary)

                                if viewModel.currentMode == .quiz {
                                    Text("Quiz Me")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentMode == .quiz ? Color.blue.opacity(0.1) : Color.clear)
                            )
                        }

                        // Learning Lens
                        Menu {
                            ForEach(LearningLens.availableLenses, id: \.name) { lens in
                                Button(lens.name) {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.applyLens(lens.name == "None" ? nil : lens)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image("learning_lens")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(viewModel.currentLens != nil && viewModel.currentLens?.name != "None" ? .blue : .primary)

                                if let lens = viewModel.currentLens, lens.name != "None" {
                                    Text(lens.name)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.blue)
                                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .leading)))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentLens != nil && viewModel.currentLens?.name != "None" ? Color.blue.opacity(0.1) : Color.clear)
                            )
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle(viewModel.session.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.sessionTimer.isActive)
        .toolbar {
            // Custom back button when timer is active
            if viewModel.sessionTimer.isActive {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.showNavigationAlert = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Timer button - shows clock or progress
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        if viewModel.sessionTimer.isActive {
                            viewModel.isShowingTimerDetail = true
                        } else {
                            viewModel.isShowingTimerSelection = true
                        }
                    }) {
                        if viewModel.sessionTimer.isActive {
                            CircularProgressTimer(timer: viewModel.sessionTimer)
                        } else {
                            Image(systemName: "clock")
                                .font(.system(size: 20))
                        }
                    }

                    Button(action: {
                        viewModel.handleFrustrationButton()
                    }) {
                        Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.system(size: 20))

                    }
                    .disabled(viewModel.isFrustrationButtonDisabled)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingModeSelection) {
            ModeSelectionSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowingTimerSelection) {
            TimerSelectionSheet(isPresented: $viewModel.isShowingTimerSelection) { minutes in
                viewModel.startTimer(minutes: minutes)
            }
        }
        .sheet(isPresented: $viewModel.isShowingTimerDetail) {
            TimerDetailSheet(
                timer: viewModel.sessionTimer,
                isPresented: $viewModel.isShowingTimerDetail,
                onEndSession: {
                    viewModel.endTimer()
                }
            )
        }
        .sheet(isPresented: $viewModel.isShowingQuizTypeSelection) {
            QuizTypeSelectionSheet(viewModel: viewModel)
        }
        .alert("Mimic Mode", isPresented: $viewModel.showCustomEntityAlert) {
            TextField("Entity name", text: $viewModel.customEntityName)
            Button("OK") { }
            Button("Cancel", role: .cancel) {
                viewModel.currentMode = .standard
            }
        } message: {
            Text("Who would you like Claude to act as?")
        }
        .alert("End Timer Session?", isPresented: $viewModel.showNavigationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave Anyway", role: .destructive) {
                viewModel.endTimer()
                dismiss()
            }
        } message: {
            Text("Leaving will end your current timer session. You can always start a new one later.")
        }
        .overlay(alignment: .top) {
            // Frustration button toast message
            if let toastMessage = viewModel.frustrationToastMessage {
                Text(toastMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.claudeOrange)
                    .cornerRadius(20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.frustrationToastMessage)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    var isStreaming: Bool = false
    var viewModel: ChatViewModel? = nil

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if let mode = message.activeMode, mode != .standard {
                    HStack(spacing: 4) {
                        Image(mode.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .foregroundColor(.secondary)
                        Text(mode.rawValue)
                            .font(.caption2)
                        if let lens = message.activeLens {
                            Text("• \(lens)")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(.secondary)
                }

                HStack {
                    // Check if this is a quiz message with quiz data
                    if let quizData = message.quizData {
                        // Render quiz-specific UI
                        QuizMessageView(quizData: quizData, message: message, viewModel: viewModel!)
                            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
                    } else {
                        // Normal markdown content
                        Markdown(message.content)
                            .padding(.horizontal, message.role == .user ? 16 : 0)
                            .padding(.vertical, message.role == .user ? 10 : 0)
                            .background(
                                message.role == .user ?
                                Color.tileBackground : Color.clear
                            )
                            .foregroundColor(.primary)
                            .cornerRadius(message.role == .user ? 16 : 0)
                    }

                    if isStreaming && message.role == .assistant && message.quizData == nil {
                        ProgressView()
                            .scaleEffect(0.6)
                            .padding(.leading, 4)
                    }
                }
            }

            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

struct EmptyStateView: View {
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Image("book")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)

            Text("What are we learning today?")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
