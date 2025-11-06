import SwiftUI
import UIKit

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
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredSpaces) { space in
                            SpaceTile(space: space)
                                .onTapGesture {
                                    viewModel.updateSpaceAccessTime(space)
                                    selectedSpace = space
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }

                // Bottom toolbar
                HStack(spacing: 12) {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.63))
                            .font(.system(size: 15, weight: .regular))
                        TextField("Search", text: $viewModel.searchText)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                    .cornerRadius(10)

                    // Add button
                    Button(action: {
                        viewModel.isShowingCreateSpace = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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
        VStack(spacing: 8) {
            // Custom icon or fallback to SF Symbol
            if UIImage(named: space.icon) != nil {
                Image(space.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .opacity(0.8)
            } else {
                // Fallback to SF Symbol for custom spaces
                Image(systemName: space.icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(width: 28, height: 28)
            }

            Text(space.name)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13)) // Off-black
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding(.horizontal, 12)
        .background(Color(red: 0.93, green: 0.91, blue: 0.87))
        .cornerRadius(16)
    }
}

#Preview {
    SpacesGridView()
}
