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
                HStack {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search", text: $viewModel.searchText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    Spacer()

                    // Add button
                    Button(action: {
                        viewModel.isShowingCreateSpace = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding()
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
                .font(.system(size: 36))
                .foregroundColor(.primary)

            Text(space.name)
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    SpacesGridView()
}