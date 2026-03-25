import SwiftUI

struct CharacterRowView: View {
    let character: Character

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: character.imageURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Color.gray.opacity(0.2).overlay(ProgressView())
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)
                    .lineLimit(1)
                StatusBadgeView(status: character.status)
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
