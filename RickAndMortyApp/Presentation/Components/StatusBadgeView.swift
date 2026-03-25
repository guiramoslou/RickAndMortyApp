import SwiftUI

struct StatusBadgeView: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
    }

    private var color: Color {
        switch status {
        case .alive:   return .green
        case .dead:    return .red
        case .unknown: return Color(.systemGray)
        }
    }
}
