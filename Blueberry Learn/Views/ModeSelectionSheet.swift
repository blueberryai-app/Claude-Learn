import SwiftUI

struct ModeSelectionSheet: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // File attachment options (UI only for POC)
                HStack(spacing: 20) {
                    AttachmentOption(icon: "camera", label: "Camera")
                    AttachmentOption(icon: "photo", label: "Photos")
                    AttachmentOption(icon: "folder", label: "Files")
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)

                // Learning modes
                VStack(spacing: 16) {
                    ForEach(LearningMode.allCases, id: \.self) { mode in
                        if mode != .standard {
                            ModeToggleRow(
                                mode: mode,
                                isSelected: viewModel.currentMode == mode,
                                action: {
                                    viewModel.switchMode(mode)
                                    if mode != .mimic {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }

                    // Learning Lens selector
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .frame(width: 30)

                        Text("Learning Lens")
                            .font(.system(size: 17))

                        Spacer()

                        Menu {
                            ForEach(LearningLens.availableLenses, id: \.name) { lens in
                                Button(lens.name) {
                                    viewModel.applyLens(lens.name == "None" ? nil : lens)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(viewModel.currentLens?.name ?? "None")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                Spacer()
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
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct AttachmentOption: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(.primary)
                .frame(width: 90, height: 64)
                .background(Color.cardBackground)
                .cornerRadius(12)

            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ModeToggleRow: View {
    let mode: LearningMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20))
                    .frame(width: 30)

                Text(mode.rawValue)
                    .font(.system(size: 17))
                    .foregroundColor(isSelected ? Color.blue : .primary)

                Spacer()

                Circle()
                    .strokeBorder(isSelected ? Color.blue : Color.secondary, lineWidth: 2)
                    .background(Circle().fill(isSelected ? Color.blue : Color.clear))
                    .overlay(
                        isSelected ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        : nil
                    )
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ModeSelectionSheet(viewModel: ChatViewModel(space: LearningSpace.mockSpaces.first!))
}
