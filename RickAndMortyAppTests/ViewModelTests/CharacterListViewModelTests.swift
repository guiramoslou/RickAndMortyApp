import XCTest
@testable import RickAndMortyApp

@MainActor
final class CharacterListViewModelTests: XCTestCase {

    private var sut: CharacterListViewModel!
    private var mockUseCase: MockFetchCharactersUseCase!

    override func setUp() async throws {
        mockUseCase = MockFetchCharactersUseCase()
        sut = CharacterListViewModel(fetchCharactersUseCase: mockUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockUseCase = nil
    }

    // MARK: - Loading State

    func test_onAppear_startsInLoadingState() async throws {
        // Given: a slow use case
        mockUseCase.result = .success(.mock(characters: [.mock()]))
        // When: onAppear is called (don't await the inner Task)
        sut.onAppear()
        // Then: view state transitions to loading synchronously
        XCTAssertEqual(sut.viewState, .loading)
    }

    // MARK: - Success

    func test_onAppear_setsLoadedStateOnSuccess() async throws {
        // Given
        let characters = (1...3).map { Character.mock(id: $0) }
        mockUseCase.result = .success(.mock(characters: characters))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertEqual(sut.viewState, .loaded)
        XCTAssertEqual(sut.characters.count, 3)
    }

    // MARK: - Error State

    func test_onAppear_setsErrorStateOn500() async throws {
        // Given
        mockUseCase.result = .failure(NetworkError.httpError(statusCode: 500))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        if case .error = sut.viewState { /* pass */ } else {
            XCTFail("Expected .error, got \(sut.viewState)")
        }
    }

    // MARK: - Empty State

    func test_onAppear_setsEmptyStateOn404() async throws {
        // Given
        mockUseCase.result = .failure(NetworkError.httpError(statusCode: 404))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertEqual(sut.viewState, .empty)
        XCTAssertTrue(sut.characters.isEmpty)
    }

    func test_emptyResultList_setsEmptyState() async throws {
        // Given: API returns 0 results
        mockUseCase.result = .success(.mock(characters: []))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertEqual(sut.viewState, .empty)
    }

    // MARK: - Pagination

    func test_canLoadMore_isTrueWhenMorePagesExist() async throws {
        // Given
        mockUseCase.result = .success(.mock(
            characters: (1...5).map { .mock(id: $0) },
            pages: 3,
            hasNext: true
        ))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertTrue(sut.canLoadMore)
    }

    func test_canLoadMore_isFalseOnLastPage() async throws {
        // Given: single page
        mockUseCase.result = .success(.mock(characters: [.mock()], pages: 1, hasNext: false))

        // When
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertFalse(sut.canLoadMore)
    }

    // MARK: - Search resets pagination

    func test_searchTextChange_resetsToPageOne() async throws {
        // Given: Load first multi-page result
        mockUseCase.result = .success(.mock(
            characters: (1...5).map { .mock(id: $0) },
            pages: 2,
            hasNext: true
        ))
        sut.onAppear()
        try await waitForState(timeout: 1)

        // Change search – debounce fires after 300ms
        mockUseCase.result = .success(.mock(characters: [.mock(id: 99, name: "Morty")]))
        sut.searchText = "Morty"

        // Wait for debounce + async fetch
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(mockUseCase.lastPage, 1, "Pagination must reset to page 1 on new search")
        XCTAssertEqual(sut.characters.first?.name, "Morty")
    }

    // MARK: - Retry

    func test_retry_refetchesCharacters() async throws {
        // Given: first call fails
        mockUseCase.result = .failure(NetworkError.httpError(statusCode: 500))
        sut.onAppear()
        try await waitForState(timeout: 1)
        XCTAssertEqual(sut.viewState, .error("Server returned error 500."))

        // When: retry with success
        mockUseCase.result = .success(.mock(characters: [.mock()]))
        sut.retry()
        try await waitForState(timeout: 1)

        // Then
        XCTAssertEqual(sut.viewState, .loaded)
    }

    // MARK: - Helpers

    /// Yields long enough for the internal `Task` to complete.
    private func waitForState(timeout: TimeInterval) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while sut.viewState == .loading || sut.viewState == .idle {
            if Date() > deadline { break }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
}
