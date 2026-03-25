import SwiftUI

struct EmptyStateView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)

            Text("No characters found")
                .font(.headline)

            if !searchText.isEmpty {
                Text("No results for \"\(searchText)\"")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
