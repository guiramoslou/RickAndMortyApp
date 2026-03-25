final class CharacterRepositoryImpl: CharacterRepository {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchCharacters(
        page: Int,
        name: String?,
        status: CharacterStatus?
    ) async throws -> PaginatedResponse<Character> {
        let endpoint = APIEndpoint.characters(page: page, name: name, status: status?.rawValue)
        return try await networkService.fetch(endpoint)
    }

    func fetchCharacter(id: Int) async throws -> Character {
        let endpoint = APIEndpoint.character(id: id)
        return try await networkService.fetch(endpoint)
    }
}
