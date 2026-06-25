import UIKit

final class ChatCoordinator: ChatCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    private var chatViewController: ChatViewController?
    private var childCoordinators: [Any] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ChatViewController()
        let presenter = ChatPresenter(chatId: "",
                                      userId: "ApphudUserID",
                                      appId: "com.test.test"
        )
        
        viewController.presenter = presenter
        viewController.coordinator = self
        presenter.view = viewController
        
        self.chatViewController = viewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - ChatCoordinatorProtocol
    
    func didTapBack() {
        navigationController.popViewController(animated: true)
    }
    
    func didTapHistory() {
        let historyCoordinator = ChatHistoryCoordinator(
            navigationController: navigationController
        )
        childCoordinators.append(historyCoordinator)
        historyCoordinator.start()
    }
}
