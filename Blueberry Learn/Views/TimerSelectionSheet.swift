import SwiftUI

struct TimerSelectionSheet: View {
    @Binding var isPresented: Bool
    let onSelection: (Int) -> Void  // Callback with minutes selected

    @State private var showingCustomInput = false
    @State private var customMinutes = ""
    @FocusState private var isCustomInputFocused: Bool

    // Preset durations in minutes
    let presets = [15, 30, 45, 60, 90, 120]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color.blueberryOrange)

                    Text("Set Session Duration")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Choose how long you'd like to study")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Preset buttons grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(presets, id: \.self) { minutes in
                        Button(action: {
                            onSelection(minutes)
                            isPresented = false
                        }) {
                            VStack(spacing: 4) {
                                Text("\(minutes)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("min")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                // Custom duration option
                if showingCustomInput {
                    HStack {
                        TextField("5-120", text: $customMinutes)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isCustomInputFocused)
                            .onSubmit {
                                submitCustomDuration()
                            }

                        Text("minutes")
                            .foregroundColor(.secondary)

                        Button("Start") {
                            submitCustomDuration()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(customMinutes.isEmpty)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: {
                        showingCustomInput = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isCustomInputFocused = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Custom Duration")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }

                Spacer()

                // Info text
                VStack(spacing: 8) {
                    Label("Your AI tutor will pace the lesson based on your selected duration", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    Label("You can continue chatting after the timer ends", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func submitCustomDuration() {
        guard let minutes = Int(customMinutes),
              minutes >= 5 && minutes <= 120 else {
            // Could show an alert here for invalid input
            return
        }

        onSelection(minutes)
        isPresented = false
    }
}

#Preview {
    TimerSelectionSheet(isPresented: .constant(true)) { minutes in
        print("Selected \(minutes) minutes")
    }
}