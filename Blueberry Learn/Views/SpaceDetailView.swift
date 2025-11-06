import SwiftUI

struct SpaceDetailView: View {
    let space: LearningSpace
    @StateObject private var viewModel: SpaceDetailViewModel
    @State private var navigateToNewChat = false
    @State private var navigateToSession: ChatSession? = nil

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
                    .background(Color.cardBackground)
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
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Chat history section
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.sessions.isEmpty {
                        // Sessions list with List for swipe actions
                        List {
                            Section {
                                ForEach(viewModel.sessions) { session in
                                    SessionCard(session: session) {
                                        navigateToSession = session
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteSession(session)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteSession(session)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            } header: {
                                Text("Your chats")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                    .textCase(nil)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
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
                navigateToNewChat = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.claudeOrange)
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
            ChatView(space: space, sessionId: nil)
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
