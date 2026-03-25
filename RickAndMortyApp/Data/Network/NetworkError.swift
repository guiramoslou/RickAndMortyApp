import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpError(let code):
            return "Server returned error \(code)."
        case .decodingError:
            return "Failed to parse the response data."
        case .networkError(let err):
            return err.localizedDescription
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
