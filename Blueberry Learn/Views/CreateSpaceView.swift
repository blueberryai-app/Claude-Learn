import SwiftUI

struct CreateSpaceView: View {
    @ObservedObject var viewModel: SpacesListViewModel
    @Environment(\.dismiss) var dismiss

    @State private var spaceName = ""
    @State private var selectedIcon = "book.fill"
    @State private var systemPrompt = ""
    @State private var isPromptExpanded = false

    let availableIcons = [
        "book.fill",
        "function",
        "atom",
        "terminal",
        "paintpalette",
        "pencil",
        "leaf.fill",
        "bolt.fill",
        "brain.head.profile",
        "globe.americas.fill"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Title section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What are you working on?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("Name your project", text: $spaceName)
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.top)

                // Icon selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose an icon for your space")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedIcon == icon ? Color.accentColor : Color(.systemGray6))
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                // System prompt section
                DisclosureGroup(
                    isExpanded: $isPromptExpanded,
                    content: {
                        TextEditor(text: $systemPrompt)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.top, 8)
                    },
                    label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hidden system prompt for Claude")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            if !isPromptExpanded && !systemPrompt.isEmpty {
                                Text(systemPrompt)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                )
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Create a Space")
                        .font(.headline)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.createSpace(
                            name: spaceName.isEmpty ? "New Space" : spaceName,
                            icon: selectedIcon,
                            systemPrompt: systemPrompt
                        )
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(spaceName.isEmpty ? .gray : .accentColor)
                    }
                    .disabled(spaceName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateSpaceView(viewModel: SpacesListViewModel())
}