@testable import RickAndMortyApp

final class MockFetchCharactersUseCase: FetchCharactersUseCaseProtocol {
    var result: Result<PaginatedResponse<Character>, Error> = .success(.mock())

    private(set) var lastPage: Int = 0
    private(set) var lastName: String?
    private(set) var lastStatus: CharacterStatus?

    func execute(
        page: Int,
        name: String?,
        status: CharacterStatus?
    ) async throws -> PaginatedResponse<Character> {
        lastPage = page
        lastName = name
        lastStatus = status
        switch result {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}
