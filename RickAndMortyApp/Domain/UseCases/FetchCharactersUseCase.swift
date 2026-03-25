protocol FetchCharactersUseCaseProtocol {
    func execute(
        page: Int,
        name: String?,
        status: CharacterStatus?
    ) async throws -> PaginatedResponse<Character>
}

struct FetchCharactersUseCase: FetchCharactersUseCaseProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(
        page: Int,
        name: String?,
        status: CharacterStatus?
    ) async throws -> PaginatedResponse<Character> {
        try await repository.fetchCharacters(page: page, name: name, status: status)
    }
}
