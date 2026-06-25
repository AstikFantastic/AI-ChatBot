import Foundation

protocol PixverseAPIClientProtocol {
    func getTemplates(applicationId: String) async throws -> GetTemplatesResponse
}

final class PixverseAPIClient: PixverseAPIClientProtocol {

    private let baseURL: URL
    private let bearerToken: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = URL(string: "https://nebulaapps.site/pixverse/api/v1")!,
        bearerToken: String,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
        self.decoder = JSONDecoder()
    }

    func getTemplates(applicationId: String) async throws -> GetTemplatesResponse {
        let url = baseURL
            .appendingPathComponent("get_templates")
            .appendingPathComponent(applicationId)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.server(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(GetTemplatesResponse.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
