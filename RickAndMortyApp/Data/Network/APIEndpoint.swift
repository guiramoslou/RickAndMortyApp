import Foundation

enum APIEndpoint {
    case characters(page: Int, name: String?, status: String?)
    case character(id: Int)

    private static let baseURL = "https://rickandmortyapi.com/api"

    var url: URL? {
        switch self {
        case .characters(let page, let name, let status):
            var components = URLComponents(string: "\(Self.baseURL)/character")
            var items: [URLQueryItem] = [URLQueryItem(name: "page", value: "\(page)")]
            if let name, !name.isEmpty {
                items.append(URLQueryItem(name: "name", value: name))
            }
            if let status {
                items.append(URLQueryItem(name: "status", value: status))
            }
            components?.queryItems = items
            return components?.url

        case .character(let id):
            return URL(string: "\(Self.baseURL)/character/\(id)")
        }
    }
}
