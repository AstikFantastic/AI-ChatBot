import Foundation

final class ChatPresenter: ChatPresenterProtocol {
    
    weak var view: ChatViewProtocol?
    private let networkService: ChatNetworkService
    
    private var chatId: String
    private let userId: String
    private let appId: String
    
    init(
        chatId: String = "",
        userId: String = "ApphudUserID",
        appId: String = "com.test.test",
        networkService: ChatNetworkService = ChatNetworkService()
    ) {
        self.chatId = chatId
        self.userId = userId
        self.appId = appId
        self.networkService = networkService
    }
    
    func viewDidLoad() {
        if !chatId.isEmpty {
            loadChatHistory()
        }
    }
    
    func loadChatHistory() {
        guard !chatId.isEmpty else { return }
        view?.showLoading()
        
        networkService.fetchChatMessages(chatId: chatId, userId: userId, appId: appId) { [weak self] result in
            self?.view?.hideLoading()
            
            switch result {
            case .success(let messages):
                for message in messages {
                    let bubble = MessageBubble(
                        text: message.content,
                        isUser: message.isUser,
                        timestamp: message.date ?? Date()
                    )
                    self?.view?.displayMessage(bubble)
                }
                
            case .failure(let error):
                self?.view?.showError("Failed to load chat history: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let isNewChat = chatId.isEmpty
        if isNewChat {
            let timestamp = Int(Date().timeIntervalSince1970)
            let random = Int.random(in: 1000...9999)
            chatId = "chat-\(timestamp)-\(random)"
        }
        
        let userMessage = MessageBubble(text: text,
                                        isUser: true,
                                        timestamp: Date()
        )
        view?.displayMessage(userMessage)
        view?.showLoading()
        
        networkService.sendMessage(chatId: chatId,
                                   message: text,
                                   userId: userId,
                                   appId: appId
        ) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.view?.hideLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let assistantMessage = MessageBubble(
                            text: response.assistantMessage,
                            isUser: false,
                            timestamp: Date()
                        )
                        self?.view?.displayMessage(assistantMessage)
                    }
                }     
            case .failure(let error):
                self?.view?.hideLoading()
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
}
