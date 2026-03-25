import Foundation

final class URLSessionNetworkService: NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw NetworkError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
