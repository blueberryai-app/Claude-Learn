import SwiftUI

struct SpaceDetailView: View {
    let space: LearningSpace
    @State private var showChat = false
    @State private var messages: [ChatMessage] = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Conversation history visualization
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your history")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                ForEach(0..<14, id: \.self) { index in
                                    ConversationSquare(intensity: Double.random(in: 0.3...1.0))
                                }
                            }
                            HStack(spacing: 6) {
                                ForEach(0..<14, id: \.self) { index in
                                    ConversationSquare(intensity: Double.random(in: 0.3...1.0))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 50)
                }
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Files and Instructions sections
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

                // Empty state with chat prompt
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

            // Floating action button
            Button(action: {
                showChat = true
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
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(red: 0.76 * intensity, green: 0.44 * intensity, blue: 0.35 * intensity))
            .frame(width: 24, height: 24)
    }
}

#Preview {
    NavigationStack {
        SpaceDetailView(space: LearningSpace.mockSpaces.first!)
    }
}