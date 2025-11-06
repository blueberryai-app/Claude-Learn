import SwiftUI

struct ChatView: View {
    let space: LearningSpace
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    init(space: LearningSpace) {
        self.space = space
        self._viewModel = StateObject(wrappedValue: ChatViewModel(space: space))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.messages.isEmpty {
                            EmptyStateView(icon: space.icon)
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
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
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 12) {
                    // Attachment buttons
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }

                        Button(action: {}) {
                            Image(systemName: "doc.text")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }

                        Button(action: {
                            viewModel.isShowingModeSelection.toggle()
                        }) {
                            Image(systemName: viewModel.currentMode.icon)
                                .font(.title3)
                                .foregroundColor(viewModel.currentMode == .standard ? .primary : .accentColor)
                        }

                        Button(action: {}) {
                            Image(systemName: "theatermasks")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }

                        Button(action: {}) {
                            Image(systemName: "doc.on.clipboard")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }

                    // Input field
                    HStack {
                        TextField("I want to learn more about \(space.name.lowercased())", text: $viewModel.inputText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isInputFocused)
                            .onSubmit {
                                viewModel.sendMessage()
                            }

                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.inputText.isEmpty ? .gray : .orange)
                        }
                        .disabled(viewModel.inputText.isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                }
                .padding()
            }
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "clock")
                    }
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingModeSelection) {
            ModeSelectionSheet(viewModel: viewModel)
        }
        .alert("Custom Entity", isPresented: $viewModel.showCustomEntityAlert) {
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

                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user ?
                        Color.blue : Color(.systemGray6)
                    )
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)
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
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .padding()

            Text("What are we learning today?")
                .font(.title2)
                .foregroundColor(.secondary)
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