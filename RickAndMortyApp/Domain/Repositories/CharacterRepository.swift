protocol CharacterRepository {
    func fetchCharacters(
        page: Int,
        name: String?,
        status: CharacterStatus?
    ) async throws -> PaginatedResponse<Character>

    func fetchCharacter(id: Int) async throws -> Character
}
