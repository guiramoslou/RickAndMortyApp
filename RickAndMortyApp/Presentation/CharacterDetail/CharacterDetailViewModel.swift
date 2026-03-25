import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {

    enum ViewState {
        case idle
        case loading
        case loaded(Character)
        case error(String)
    }

    @Published private(set) var viewState: ViewState = .idle

    private let characterId: Int
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCaseProtocol

    init(characterId: Int, fetchCharacterDetailUseCase: FetchCharacterDetailUseCaseProtocol) {
        self.characterId = characterId
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
    }

    func onAppear() {
        guard case .idle = viewState else { return }
        fetchCharacter()
    }

    func retry() {
        fetchCharacter()
    }

    private func fetchCharacter() {
        viewState = .loading
        Task {
            do {
                let character = try await fetchCharacterDetailUseCase.execute(id: characterId)
                viewState = .loaded(character)
            } catch let error as NetworkError {
                viewState = .error(error.localizedDescription)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
