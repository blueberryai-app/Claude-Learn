import SwiftUI

struct SpacesGridView: View {
    @StateObject private var viewModel = SpacesListViewModel()
    @State private var selectedSpace: LearningSpace?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main content
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.filteredSpaces) { space in
                            SpaceTile(space: space)
                                .onTapGesture {
                                    viewModel.updateSpaceAccessTime(space)
                                    selectedSpace = space
                                }
                        }
                    }
                    .padding()
                }

                // Bottom toolbar
                HStack(spacing: 16) {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        TextField("Search", text: $viewModel.searchText)
                            .font(.system(size: 17))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Add button
                    Button(action: {
                        viewModel.isShowingCreateSpace = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Learning Spaces")
            .navigationDestination(item: $selectedSpace) { space in
                SpaceDetailView(space: space)
            }
            .sheet(isPresented: $viewModel.isShowingCreateSpace) {
                CreateSpaceView(viewModel: viewModel)
            }
        }
    }
}

struct SpaceTile: View {
    let space: LearningSpace

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: space.icon)
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.primary)
                .frame(height: 60)

            Text(space.name)
                .font(.system(size: 17, weight: .regular))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color(red: 0.93, green: 0.91, blue: 0.87))
        .cornerRadius(20)
    }
}

#Preview {
    SpacesGridView()
}