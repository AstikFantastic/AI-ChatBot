import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(statusCode: Int, data: Data?)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный URL запроса."
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."
        case .server(let statusCode, _):
            return "Ошибка сервера: \(statusCode)."
        case .decoding:
            return "Не удалось разобрать ответ сервера."
        case .transport(let error):
            return error.localizedDescription
        }
    }
}
