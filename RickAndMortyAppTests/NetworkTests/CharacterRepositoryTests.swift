import XCTest
@testable import RickAndMortyApp

final class CharacterRepositoryTests: XCTestCase {

    private var sut: CharacterRepositoryImpl!
    private var mockNetwork: MockNetworkService!

    override func setUp() {
        mockNetwork = MockNetworkService()
        sut = CharacterRepositoryImpl(networkService: mockNetwork)
    }

    override func tearDown() {
        sut = nil
        mockNetwork = nil
    }

    // MARK: - fetchCharacters

    func test_fetchCharacters_decodesSuccessfully() async throws {
        // Given
        let characters = [Character.mock(id: 1), Character.mock(id: 2)]
        let expected = PaginatedResponse<Character>.mock(characters: characters)
        mockNetwork.setResponse(expected)

        // When
        let result = try await sut.fetchCharacters(page: 1, name: nil, status: nil)

        // Then
        XCTAssertEqual(result.results.count, 2)
        XCTAssertEqual(result.results[0].id, 1)
        XCTAssertEqual(result.results[1].id, 2)
        XCTAssertEqual(result.info.count, 2)
    }

    func test_fetchCharacters_propagatesHTTPError() async {
        // Given
        mockNetwork.mockError = NetworkError.httpError(statusCode: 404)

        // When / Then
        do {
            _ = try await sut.fetchCharacters(page: 1, name: nil, status: nil)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            guard case .httpError(let code) = error else {
                return XCTFail("Expected httpError, got \(error)")
            }
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchCharacters_propagatesDecodingError() async {
        // Given
        let decodingError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "mock")
        )
        mockNetwork.mockError = NetworkError.decodingError(decodingError)

        // When / Then
        do {
            _ = try await sut.fetchCharacters(page: 1, name: nil, status: nil)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .decodingError = error { /* pass */ } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_fetchCharacters_propagatesNetworkError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        mockNetwork.mockError = NetworkError.networkError(urlError)

        // When / Then
        do {
            _ = try await sut.fetchCharacters(page: 1, name: nil, status: nil)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .networkError = error { /* pass */ } else {
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - fetchCharacter (single)

    func test_fetchCharacter_decodesSuccessfully() async throws {
        // Given
        let expected = Character.mock(id: 42, name: "Morty Smith")
        mockNetwork.setResponse(expected)

        // When
        let result = try await sut.fetchCharacter(id: 42)

        // Then
        XCTAssertEqual(result.id, 42)
        XCTAssertEqual(result.name, "Morty Smith")
    }

    func test_fetchCharacter_propagatesHTTPError() async {
        // Given
        mockNetwork.mockError = NetworkError.httpError(statusCode: 500)

        // When / Then
        do {
            _ = try await sut.fetchCharacter(id: 1)
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .httpError(500) = error { /* pass */ } else {
                XCTFail("Expected httpError(500), got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
