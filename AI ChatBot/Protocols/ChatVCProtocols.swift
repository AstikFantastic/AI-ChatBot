import Foundation

protocol ChatPresenterProtocol: AnyObject {
    func sendMessage(_ text: String)
    func viewDidLoad()
    func loadChatHistory()
}

protocol ChatViewProtocol: AnyObject {
    func displayMessage(_ message: MessageBubble)
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func clearMessages()
}
