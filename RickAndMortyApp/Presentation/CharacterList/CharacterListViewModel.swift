import Foundation
import Combine

@MainActor
final class CharacterListViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    // MARK: - Published

    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var characters: [Character] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: CharacterStatus? = nil
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var canLoadMore: Bool = false

    // MARK: - Private

    private let fetchCharactersUseCase: FetchCharactersUseCaseProtocol
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var fetchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(fetchCharactersUseCase: FetchCharactersUseCaseProtocol) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        setupObservers()
    }

    // MARK: - Public API

    func onAppear() {
        guard viewState == .idle else { return }
        fetchCharacters(reset: true)
    }

    func retry() {
        viewState = .idle
        fetchCharacters(reset: true)
    }

    func loadMore() {
        guard canLoadMore, !isLoadingMore, viewState == .loaded else { return }
        isLoadingMore = true
        currentPage += 1
        fetchCharacters(reset: false)
    }

    // MARK: - Private

    private func setupObservers() {
        Publishers.CombineLatest($searchText, $selectedStatus)
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
                self?.resetAndFetch()
            }
            .store(in: &cancellables)
    }

    private func resetAndFetch() {
        fetchTask?.cancel()
        currentPage = 1
        characters = []
        canLoadMore = false
        isLoadingMore = false
        fetchCharacters(reset: true)
    }

    private func fetchCharacters(reset: Bool) {
        if reset {
            viewState = .loading
        }

        fetchTask = Task {
            do {
                let response = try await fetchCharactersUseCase.execute(
                    page: currentPage,
                    name: searchText.isEmpty ? nil : searchText,
                    status: selectedStatus
                )

                guard !Task.isCancelled else { return }

                if reset {
                    characters = response.results
                } else {
                    characters += response.results
                }

                totalPages = response.info.pages
                canLoadMore = currentPage < totalPages
                isLoadingMore = false
                viewState = characters.isEmpty ? .empty : .loaded

            } catch is CancellationError {
                // Intentionally ignored – triggered by a new search/filter.
            } catch let error as NetworkError {
                guard !Task.isCancelled else { return }
                isLoadingMore = false
                if case .httpError(let code) = error, code == 404 {
                    characters = []
                    canLoadMore = false
                    viewState = .empty
                } else {
                    viewState = .error(error.localizedDescription)
                }
            } catch {
                guard !Task.isCancelled else { return }
                isLoadingMore = false
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
