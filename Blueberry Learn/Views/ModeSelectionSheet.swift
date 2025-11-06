import SwiftUI

struct ModeSelectionSheet: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedLens = "Star Wars"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // File attachment options (UI only for POC)
                HStack(spacing: 20) {
                    AttachmentOption(icon: "camera", label: "Camera")
                    AttachmentOption(icon: "photo", label: "Photos")
                    AttachmentOption(icon: "folder", label: "Files")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()

                // Learning modes
                VStack(spacing: 16) {
                    ForEach(LearningMode.allCases, id: \.self) { mode in
                        if mode != .standard {
                            ModeToggleRow(
                                mode: mode,
                                isSelected: viewModel.currentMode == mode,
                                action: {
                                    viewModel.switchMode(mode)
                                    if mode != .customEntity {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }

                    // Learning Lens selector
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.title3)

                        Text("Learning Lens")
                            .font(.body)

                        Spacer()

                        Menu {
                            ForEach(LearningLens.availableLenses, id: \.name) { lens in
                                Button(lens.name) {
                                    selectedLens = lens.name
                                    viewModel.applyLens(lens.name == "None" ? nil : lens)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedLens)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Education Modes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct AttachmentOption: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 60, height: 60)
                .background(Color(.systemBackground))
                .cornerRadius(12)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ModeToggleRow: View {
    let mode: LearningMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ModeSelectionSheet(viewModel: ChatViewModel(space: LearningSpace.mockSpaces.first!))
}