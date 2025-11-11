import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var customAPIKey: String = ""
    @State private var showPasswordAlert = false
    @State private var passwordInput = ""
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var isEducationTeamUnlocked = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 24)

                // Education Team Section (shown if unlocked)
                if isEducationTeamUnlocked {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.claudeOrange)

                            Text("Education Team Access")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }

                        Text("You're using the education team API key")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                } else {
                    // Custom API Key Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("API Key")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)

                        TextField("sk-ant-...", text: $customAPIKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 14, design: .monospaced))
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        Button(action: {
                            saveCustomAPIKey()
                        }) {
                            Text("Save API Key")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(customAPIKey.isEmpty ? Color.gray.opacity(0.5) : Color.claudeOrange)
                                .cornerRadius(12)
                        }
                        .disabled(customAPIKey.isEmpty)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                        .padding(.vertical, 8)

                    // Education Team Button
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Education Team")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)

                        Button(action: {
                            showPasswordAlert = true
                        }) {
                            HStack {
                                Image(systemName: "graduationcap.fill")
                                    .font(.system(size: 16))

                                Text("Access education team key")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.claudeOrange)
                            .cornerRadius(12)
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert("Education Team Access", isPresented: $showPasswordAlert) {
                SecureField("Enter password", text: $passwordInput)
                Button("Cancel", role: .cancel) {
                    passwordInput = ""
                }
                Button("Unlock") {
                    validatePassword()
                }
            } message: {
                Text("Enter password to access education team key")
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {}
            } message: {
                Text("Education team access unlocked")
            }
            .alert("Incorrect Password", isPresented: $showErrorAlert) {
                Button("OK") {
                    passwordInput = ""
                }
            } message: {
                Text("Please try again")
            }
            .onAppear {
                loadSettings()
            }
        }
    }

    private func loadSettings() {
        customAPIKey = StorageService.shared.loadCustomAPIKey() ?? ""
        isEducationTeamUnlocked = StorageService.shared.isEducationTeamUnlocked()
    }

    private func saveCustomAPIKey() {
        StorageService.shared.saveCustomAPIKey(customAPIKey)
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func validatePassword() {
        if passwordInput == APIConfiguration.educationTeamPassword {
            // Correct password
            StorageService.shared.setEducationTeamUnlocked(true)
            isEducationTeamUnlocked = true
            passwordInput = ""
            showSuccessAlert = true

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Incorrect password
            showErrorAlert = true

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    SettingsView()
}
