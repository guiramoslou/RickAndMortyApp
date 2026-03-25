@testable import RickAndMortyApp

/// Type-erased mock for NetworkService.
/// Store a typed result via `setResult(_:)`, then the generic `fetch` will cast it.
final class MockNetworkService: NetworkService {
    private var _response: Any?
    var mockError: Error?

    func setResponse<T: Decodable>(_ value: T) {
        _response = value
    }

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if let error = mockError { throw error }
        guard let value = _response as? T else {
            throw NetworkError.unknown
        }
        return value
    }
}
