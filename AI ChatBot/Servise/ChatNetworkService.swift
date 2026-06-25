import UIKit

final class ChatNetworkService {
    
    private let baseURL = "https://nebulaapps.site/dola"
    private let token = AppConfig.pixverseBearerToken
    
    func sendMessage(
        chatId: String,
        message: String,
        userId: String,
        appId: String,
        personaId: String? = nil,
        additionalPrompt: String? = nil,
        completion: @escaping (Result<ChatResponse, Error>) -> Void
    ) {
        sendMessageToChat(chatId: chatId,
                          message: message,
                          userId: userId,
                          appId: appId,
                          personaId: personaId,
                          additionalPrompt: additionalPrompt,
                          completion: completion
        )
    }
    
    private func sendMessageToChat(chatId: String,
                                   message: String,
                                   userId: String,
                                   appId: String,
                                   personaId: String?,
                                   additionalPrompt: String?,
                                   completion: @escaping (Result<ChatResponse, Error>) -> Void
    ) {
        let urlString = "\(baseURL)/chats/\(chatId)/messages"
        
        var components = URLComponents(string: urlString)
        components?.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "app_id", value: appId)
        ]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = ChatMessage(message: message, personaId: personaId, additionalPrompt: additionalPrompt)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("\(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data from server")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ChatResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch let DecodingError.keyNotFound(key, context) {
                let decodingError = DecodingError.keyNotFound(key, context)
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            } catch let DecodingError.typeMismatch(type, context) {
                let decodingError = DecodingError.typeMismatch(type, context)
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchChatMessages(chatId: String,
                           userId: String,
                           appId: String,
                           offset: Int = 0,
                           limit: Int? = nil,
                           completion: @escaping (Result<[ChatHistoryMessage], Error>) -> Void
    ) {
        var components = URLComponents(string: "\(baseURL)/chats/\(chatId)/messages")
        var queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                print("No data from server")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("\(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let messages = try decoder.decode([ChatHistoryMessage].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                print("\(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
