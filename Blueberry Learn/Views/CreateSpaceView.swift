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
            ScrollView {
                VStack(spacing: 20) {
                    // Title section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What are you working on?")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)

                        TextField("Name your project", text: $spaceName)
                            .font(.system(size: 17))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Icon selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose an icon for your space")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)

                        HStack(spacing: 12) {
                            ForEach(availableIcons.prefix(6), id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(selectedIcon == icon ? .white : Color(.systemGray))
                                        .frame(width: 52, height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedIcon == icon ? Color.blue : Color(.systemGray6))
                                        )
                                }
                            }

                            // More icon button
                            Button(action: {}) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .frame(width: 52, height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // System prompt section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hidden system prompt for Claude")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)

                        HStack(alignment: .top, spacing: 12) {
                            Text("A placeholder bunch of text here, we will fill in later, and ther will be a collapsable carrot next to it...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(3)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Create a Space")
                        .font(.system(size: 17, weight: .semibold))
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
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(spaceName.isEmpty ? Color(.systemGray3) : Color(.systemGray))
                            .clipShape(Circle())
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