import UIKit

final class ChatHistoryNetworkService {
    
    private let baseURL = "https://nebulaapps.site/dola/chats"
    private let token = AppConfig.pixverseBearerToken
    
    func fetchChats(userId: String,
                    appId: String,
                    offset: Int = 0,
                    limit: Int? = nil,
                    completion: @escaping (Result<[ChatHistoryItem], Error>) -> Void
    ) {
        var components = URLComponents(string: baseURL)
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
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let chats = try decoder.decode([ChatHistoryItem].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(chats))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

