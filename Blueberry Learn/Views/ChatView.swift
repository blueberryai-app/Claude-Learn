import SwiftUI

struct ChatView: View {
    let space: LearningSpace
    let sessionId: UUID?
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    init(space: LearningSpace, sessionId: UUID? = nil) {
        self.space = space
        self.sessionId = sessionId
        self._viewModel = StateObject(wrappedValue: ChatViewModel(space: space, sessionId: sessionId))
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
                            EmptyStateView(icon: space.icon)
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message, isStreaming: viewModel.isLoading && message.id == viewModel.messages.last?.id)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input toolbar
            VStack(spacing: 12) {
                Divider()

                VStack(spacing: 12) {
                    // Input field
                    HStack(spacing: 8) {
                        TextField("I want to learn more about \(space.name.lowercased())", text: $viewModel.inputText)
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
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(viewModel.inputText.isEmpty ? Color.gray : Color(red: 0.76, green: 0.44, blue: 0.35))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.inputText.isEmpty)
                    }

                    // Mode selector buttons
                    HStack(spacing: 16) {
                        // Plus button to open full mode selection
                        Button(action: {
                            viewModel.isShowingModeSelection.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                                .frame(width: 32, height: 32)
                        }

                        // Writing Mode
                        Button(action: {
                            viewModel.switchMode(.writing)
                        }) {
                            Image("writing_mode")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentMode == .writing ? .blue : .primary)
                                .frame(width: 32, height: 32)
                        }

                        // Debate Me
                        Button(action: {
                            viewModel.switchMode(.debate)
                        }) {
                            Image("debate_mode")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentMode == .debate ? .blue : .primary)
                                .frame(width: 32, height: 32)
                        }

                        // Mimic Mode
                        Button(action: {
                            viewModel.switchMode(.mimic)
                        }) {
                            Image("custom_entity")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentMode == .mimic ? .blue : .primary)
                                .frame(width: 32, height: 32)
                        }

                        // Quiz Me
                        Button(action: {
                            viewModel.switchMode(.quiz)
                        }) {
                            Image("quiz_me")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(viewModel.currentMode == .quiz ? .blue : .primary)
                                .frame(width: 32, height: 32)
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Timer button - shows clock or progress
                    Button(action: {
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

                    Button(action: {}) {
                        Image(systemName: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.system(size: 20))

                    }
                    .tint(.red)
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
        .alert("Mimic Mode", isPresented: $viewModel.showCustomEntityAlert) {
            TextField("Entity name", text: $viewModel.customEntityName)
            Button("OK") { }
            Button("Cancel", role: .cancel) {
                viewModel.currentMode = .standard
            }
        } message: {
            Text("Who would you like Claude to act as?")
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    var isStreaming: Bool = false

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if let mode = message.activeMode, mode != .standard {
                    HStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.caption2)
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
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            message.role == .user ?
                            Color.blue : Color(.systemGray6)
                        )
                        .foregroundColor(message.role == .user ? .white : .primary)
                        .cornerRadius(16)

                    if isStreaming && message.role == .assistant {
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
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

#Preview {
    NavigationStack {
        ChatView(space: LearningSpace.mockSpaces.first!)
    }
}
