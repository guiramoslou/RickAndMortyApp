protocol FetchCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> Character
}

struct FetchCharacterDetailUseCase: FetchCharacterDetailUseCaseProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Character {
        try await repository.fetchCharacter(id: id)
    }
}
