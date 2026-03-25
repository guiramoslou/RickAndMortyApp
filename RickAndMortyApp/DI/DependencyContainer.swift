import Foundation

/// Composition root: wires up all dependencies using constructor injection.
/// No global singletons are used for core dependencies (networking, repos, use-cases).
@MainActor
final class DependencyContainer {

    // MARK: - Singleton (container only, not the dependencies inside)
    static let shared = DependencyContainer()

    // MARK: - Infrastructure
    private lazy var networkService: NetworkService = URLSessionNetworkService()

    // MARK: - Repositories
    private lazy var characterRepository: CharacterRepository = CharacterRepositoryImpl(
        networkService: networkService
    )

    // MARK: - Use Cases
    private lazy var fetchCharactersUseCase: FetchCharactersUseCaseProtocol = FetchCharactersUseCase(
        repository: characterRepository
    )

    private lazy var fetchCharacterDetailUseCase: FetchCharacterDetailUseCaseProtocol = FetchCharacterDetailUseCase(
        repository: characterRepository
    )

    private init() {}

    // MARK: - Factory Methods

    func makeCharacterListViewModel() -> CharacterListViewModel {
        CharacterListViewModel(fetchCharactersUseCase: fetchCharactersUseCase)
    }

    func makeCharacterDetailViewModel(id: Int) -> CharacterDetailViewModel {
        CharacterDetailViewModel(
            characterId: id,
            fetchCharacterDetailUseCase: fetchCharacterDetailUseCase
        )
    }
}
