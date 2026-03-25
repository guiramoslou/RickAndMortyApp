import SwiftUI

@main
struct RickAndMortyApp: App {
    var body: some Scene {
        WindowGroup {
            CharacterListView(
                viewModel: DependencyContainer.shared.makeCharacterListViewModel(),
                detailViewModelFactory: { id in
                    DependencyContainer.shared.makeCharacterDetailViewModel(id: id)
                }
            )
        }
    }
}
	
