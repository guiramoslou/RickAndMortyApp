import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
            Spacer(minLength: 0)
        }
        .font(.subheadline)
    }
}
