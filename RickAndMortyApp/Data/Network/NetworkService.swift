protocol NetworkService {
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}
