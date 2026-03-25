@testable import RickAndMortyApp

extension Character {
    static func mock(
        id: Int = 1,
        name: String = "Rick Sanchez",
        status: CharacterStatus = .alive,
        species: String = "Human"
    ) -> Character {
        Character(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: .male,
            origin: CharacterLocation(name: "Earth (C-137)", url: ""),
            location: CharacterLocation(name: "Citadel of Ricks", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/\(id).jpeg",
            episode: ["https://rickandmortyapi.com/api/episode/1"],
            url: "https://rickandmortyapi.com/api/character/\(id)",
            created: "2017-11-04T18:48:46.250Z"
        )
    }
}

extension PaginatedResponse where T == Character {
    static func mock(
        characters: [Character] = [.mock()],
        pages: Int = 1,
        hasNext: Bool = false
    ) -> PaginatedResponse<Character> {
        PaginatedResponse(
            info: PageInfo(
                count: characters.count,
                pages: pages,
                next: hasNext ? "https://rickandmortyapi.com/api/character?page=2" : nil,
                prev: nil
            ),
            results: characters
        )
    }
}
