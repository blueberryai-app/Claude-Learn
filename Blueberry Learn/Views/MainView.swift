import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var navigateToNewChat = false
    @State private var navigateToSession: ChatSession? = nil
    @State private var showFilesInfo = false
    @State private var showInstructionsInfo = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Files and Instructions sections - ALWAYS visible at top
                    HStack(spacing: 16) {
                        // Files section
                        Button(action: {
                            showFilesInfo = true
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Files")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("Add PDFs, docs, or other text to use in this project.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Color.cardBackground)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Instructions section
                        Button(action: {
                            showInstructionsInfo = true
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Instructions")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
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
                        .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Claude Learn")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadSessions()
            }
            .navigationDestination(isPresented: $navigateToNewChat) {
                ChatView(sessionId: nil)
            }
            .navigationDestination(item: $navigateToSession) { session in
                ChatView(sessionId: session.id)
            }
            .sheet(isPresented: $showFilesInfo) {
                FilesInfoSheet()
            }
            .sheet(isPresented: $showInstructionsInfo) {
                InstructionsInfoSheet()
            }
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

// Files Info Sheet
struct FilesInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Files")
                        .font(.system(size: 24, weight: .bold))

//                    Text("This is a prototype feature")
//                        .font(.system(size: 15))
//                        .foregroundColor(.secondary)
                }

                // Production feature description
                Text("In the real production app, this is where you could upload and manage files to give Claude context:")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Examples
                VStack(alignment: .leading, spacing: 12) {
                    FeatureExample(
                        icon: "doc.text",
                        title: "Class materials",
                        description: "Upload lecture slides, study guides, or textbook PDFs"
                    )

                    FeatureExample(
                        icon: "calendar",
                        title: "Reference by date",
                        description: "\"What did we cover on October 15th?\""
                    )

                    FeatureExample(
                        icon: "folder",
                        title: "Organize by subject",
                        description: "Group files by course or topic"
                    )
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// Instructions Info Sheet
struct InstructionsInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.system(size: 24, weight: .bold))

//                    Text("This is a prototype feature")
//                        .font(.system(size: 15))
//                        .foregroundColor(.secondary)
                }

                // Production feature description
                Text("In the real production app, this is where you could create custom instructions to personalize how Claude helps you:")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Examples
                VStack(alignment: .leading, spacing: 12) {
                    FeatureExample(
                        icon: "person.text.rectangle",
                        title: "Learning style",
                        description: "\"I learn best with visual examples\""
                    )

                    FeatureExample(
                        icon: "graduationcap",
                        title: "Academic level",
                        description: "\"I'm a high school senior taking AP Calculus\""
                    )

                    FeatureExample(
                        icon: "target",
                        title: "Study goals",
                        description: "\"Help me prepare for the SAT Math section\""
                    )
                }

                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// Helper component for feature examples
struct FeatureExample: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.claudeOrange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    MainView()
}
