import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel
    private let detailViewModelFactory: (Int) -> CharacterDetailViewModel

    init(
        viewModel: CharacterListViewModel,
        detailViewModelFactory: @escaping (Int) -> CharacterDetailViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailViewModelFactory = detailViewModelFactory
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                stateContent
            }
            .navigationTitle("Rick & Morty")
            .searchable(text: $viewModel.searchText, prompt: "Search characters…")
            .navigationDestination(for: Int.self) { id in
                CharacterDetailView(viewModel: detailViewModelFactory(id))
            }
        }
        .onAppear { viewModel.onAppear() }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: viewModel.selectedStatus == nil) {
                    viewModel.selectedStatus = nil
                }
                ForEach(CharacterStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.displayName,
                        isSelected: viewModel.selectedStatus == status
                    ) {
                        viewModel.selectedStatus = viewModel.selectedStatus == status ? nil : status
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: - State Content

    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.viewState {
        case .loading:
            LoadingView()
        case .error(let message):
            ErrorView(message: message, onRetry: viewModel.retry)
        case .empty:
            EmptyStateView(searchText: viewModel.searchText)
        case .loaded, .idle:
            characterList
        }
    }

    // MARK: - Character List

    private var characterList: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(value: character.id) {
                    CharacterRowView(character: character)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            if viewModel.canLoadMore {
                loadMoreRow
            }
        }
        .listStyle(.plain)
        .refreshable { viewModel.retry() }
    }

    @ViewBuilder
    private var loadMoreRow: some View {
        HStack {
            Spacer()
            if viewModel.isLoadingMore {
                ProgressView()
                    .padding(.vertical, 12)
            } else {
                Button("Load More") { viewModel.loadMore() }
                    .buttonStyle(.bordered)
                    .padding(.vertical, 8)
            }
            Spacer()
        }
        .listRowSeparator(.hidden)
        .onAppear { viewModel.loadMore() }
    }
}
