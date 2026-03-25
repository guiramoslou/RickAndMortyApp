import Foundation

struct Character: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: CharacterGender
    let origin: CharacterLocation
    let location: CharacterLocation
    let image: String
    let episode: [String]
    let url: String
    let created: String

    var episodeCount: Int { episode.count }
    var imageURL: URL? { URL(string: image) }
}

struct CharacterLocation: Codable, Equatable, Hashable {
    let name: String
    let url: String
}

enum CharacterStatus: String, Codable, CaseIterable, Equatable {
    case alive   = "Alive"
    case dead    = "Dead"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .alive:   return "Alive"
        case .dead:    return "Dead"
        case .unknown: return "Unknown"
        }
    }
}

enum CharacterGender: String, Codable, Equatable {
    case female     = "Female"
    case male       = "Male"
    case genderless = "Genderless"
    case unknown    = "unknown"

    var displayName: String {
        switch self {
        case .female:     return "Female"
        case .male:       return "Male"
        case .genderless: return "Genderless"
        case .unknown:    return "Unknown"
        }
    }
}
