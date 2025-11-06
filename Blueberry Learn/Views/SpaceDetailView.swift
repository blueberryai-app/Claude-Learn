import SwiftUI

struct SpaceDetailView: View {
    let space: LearningSpace
    @State private var showChat = false
    @State private var messages: [ChatMessage] = []

    var body: some View {
        VStack(spacing: 0) {
            // Conversation history visualization
            VStack(alignment: .leading, spacing: 12) {
                Text("Your history")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<28, id: \.self) { index in
                            ConversationSquare(intensity: Double.random(in: 0.3...1.0))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)

            // Files and Instructions sections
            HStack(spacing: 16) {
                // Files section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Files")
                        .font(.headline)
                    Text("Add PDFs, docs, or other text to use in this project.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Instructions section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.headline)
                    Text("Add instructions to tailor Claude's responses.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()

            // Empty state with chat prompt
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: space.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Circle().fill(Color(.systemGray6)))

                Text("Chats you've had with Claude will show up here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Start chat button
            Button(action: {
                showChat = true
            }) {
                Label("Start New Chat", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding()
            }
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMessages()
        }
        .navigationDestination(isPresented: $showChat) {
            ChatView(space: space)
        }
    }

    func loadMessages() {
        messages = StorageService.shared.loadMessages(for: space.id)
    }
}

struct ConversationSquare: View {
    let intensity: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.orange.opacity(intensity))
            .frame(width: 20, height: 20)
    }
}

#Preview {
    NavigationStack {
        SpaceDetailView(space: LearningSpace.mockSpaces.first!)
    }
}