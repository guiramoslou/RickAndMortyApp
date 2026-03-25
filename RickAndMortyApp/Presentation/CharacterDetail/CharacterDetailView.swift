import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading, .idle:
            LoadingView()
        case .error(let message):
            ErrorView(message: message, onRetry: viewModel.retry)
        case .loaded(let character):
            characterDetail(character)
        }
    }

    private func characterDetail(_ character: Character) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroImage(character)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top) {
                        Text(character.name)
                            .font(.title2.bold())
                        Spacer()
                        StatusBadgeView(status: character.status)
                    }

                    Divider()

                    DetailRow(label: "Species",  value: character.species)
                    DetailRow(label: "Gender",   value: character.gender.displayName)
                    DetailRow(label: "Origin",   value: character.origin.name)
                    DetailRow(label: "Location", value: character.location.name)
                    DetailRow(label: "Episodes", value: "\(character.episodeCount)")

                    if !character.episode.isEmpty {
                        firstEpisodes(character.episode)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(character.name)
    }

    private func heroImage(_ character: Character) -> some View {
        AsyncImage(url: character.imageURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                Color.gray.opacity(0.2)
                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary))
            default:
                Color.gray.opacity(0.2).overlay(ProgressView())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .clipped()
    }

    private func firstEpisodes(_ episodes: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("First Appearances")
                .font(.headline)
                .padding(.top, 4)
            ForEach(episodes.prefix(5), id: \.self) { url in
                let ep = url.components(separatedBy: "/").last ?? url
                Label("Episode \(ep)", systemImage: "tv")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
