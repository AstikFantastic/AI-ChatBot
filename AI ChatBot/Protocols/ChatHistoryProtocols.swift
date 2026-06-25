import Foundation

protocol ChatHistoryPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refreshChats()
}

protocol ChatHistoryViewProtocol: AnyObject {
    func displayChats(_ sections: [ChatHistorySection])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func showEmptyState()
    func hideEmptyState()
}

