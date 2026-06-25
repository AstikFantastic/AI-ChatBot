import Foundation

struct ChatHistorySection {
    let title: String
    let chats: [ChatHistoryItem]
}

final class ChatHistoryPresenter: ChatHistoryPresenterProtocol {
    
    weak var view: ChatHistoryViewProtocol?
    
    private let networkService: ChatHistoryNetworkService
    private let userId: String
    private let appId: String
    private var allChats: [ChatHistoryItem] = []
    
    init(
        userId: String = "ApphudUserID",
        appId: String = "com.test.test",
        networkService: ChatHistoryNetworkService = ChatHistoryNetworkService()
    ) {
        self.userId = userId
        self.appId = appId
        self.networkService = networkService
    }
    
    func viewDidLoad() {
        loadChats()
    }
    
    func refreshChats() {
        loadChats()
    }
    
    private func loadChats() {
        view?.showLoading()
        
        networkService.fetchChats(
            userId: userId,
            appId: appId,
            offset: 0,
            limit: 100
        ) { [weak self] result in
            self?.view?.hideLoading()
            
            switch result {
            case .success(let chats):
                var seenIds = Set<String>()
                var uniqueChats = chats.filter { chat in
                    if seenIds.contains(chat.chatId) {
                        return false
                    }
                    seenIds.insert(chat.chatId)
                    return true
                }

                uniqueChats.sort { chat1, chat2 in
                    guard let date1 = chat1.date, let date2 = chat2.date else {
                        return chat1.date != nil
                    }
                    return date1 > date2
                }
                
                self?.allChats = uniqueChats
                
                if uniqueChats.isEmpty {
                    self?.view?.showEmptyState()
                } else {
                    self?.view?.hideEmptyState()
                    let sections = self?.groupChatsByDate(uniqueChats) ?? []
                    self?.view?.displayChats(sections)
                }
                
            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
    
    private func groupChatsByDate(_ chats: [ChatHistoryItem]) -> [ChatHistorySection] {
        let calendar = Calendar.current
        _ = Date()
        
        var todayChats: [ChatHistoryItem] = []
        var yesterdayChats: [ChatHistoryItem] = []
        var olderChats: [String: [ChatHistoryItem]] = [:]
        
        for chat in chats {
            guard let chatDate = chat.date else { continue }
            
            if calendar.isDateInToday(chatDate) {
                todayChats.append(chat)
            } else if calendar.isDateInYesterday(chatDate) {
                yesterdayChats.append(chat)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d"
                let key = formatter.string(from: chatDate)
                olderChats[key, default: []].append(chat)
            }
        }
        
        var sections: [ChatHistorySection] = []
        
        if !todayChats.isEmpty {
            sections.append(ChatHistorySection(title: "Today", chats: todayChats))
        }
        
        if !yesterdayChats.isEmpty {
            sections.append(ChatHistorySection(title: "Yesterday", chats: yesterdayChats))
        }
        
        let sortedOlderKeys = olderChats.keys.sorted { key1, key2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2) else {
                return key1 > key2
            }
            return date1 > date2
        }
        
        for key in sortedOlderKeys {
            if let chats = olderChats[key] {
                sections.append(ChatHistorySection(title: key, chats: chats))
            }
        }
        
        return sections
    }
}
