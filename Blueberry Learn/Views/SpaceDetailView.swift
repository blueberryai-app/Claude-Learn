import SwiftUI

struct SpaceDetailView: View {
    let space: LearningSpace
    @StateObject private var viewModel: SpaceDetailViewModel
    @State private var navigateToNewChat = false
    @State private var navigateToSession: ChatSession? = nil
    @State private var newSessionId: UUID? = nil

    init(space: LearningSpace) {
        self.space = space
        self._viewModel = StateObject(wrappedValue: SpaceDetailViewModel(space: space))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Files and Instructions sections - ALWAYS visible at top
                HStack(spacing: 16) {
                    // Files section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Files")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Add PDFs, docs, or other text to use in this project.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(12)

                    // Instructions section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Add instructions to tailor Claude's responses.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Chat history section
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.sessions.isEmpty {
                        // Header for chat sessions
                        Text("Your chats")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)

                        // Sessions list with constrained ScrollView
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.sessions) { session in
                                    SessionCard(session: session) {
                                        navigateToSession = session
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteSession(session)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    } else {
                        // Empty state centered in remaining space
                        Spacer()

                        VStack(spacing: 16) {
                            Image("message_bubbles")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)

                            Text("Chats you've had with Claude will show up here.")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
            }

            // Floating action button
            Button(action: {
                let newSession = viewModel.createNewSession()
                newSessionId = newSession.id
                navigateToNewChat = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color(red: 0.76, green: 0.44, blue: 0.35))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadSessions()
        }
        .navigationDestination(isPresented: $navigateToNewChat) {
            if let sessionId = newSessionId {
                ChatView(space: space, sessionId: sessionId)
            }
        }
        .navigationDestination(item: $navigateToSession) { session in
            ChatView(space: space, sessionId: session.id)
        }
    }
}

// Session Card Component
struct SessionCard: View {
    let session: ChatSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(session.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(session.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(session.lastMessagePreview)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        SpaceDetailView(space: LearningSpace.mockSpaces.first!)
    }
}