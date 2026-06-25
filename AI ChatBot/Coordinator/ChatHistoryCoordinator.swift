import UIKit

protocol ChatHistoryCoordinatorProtocol: AnyObject {
    func didTapBack()
}

final class ChatHistoryCoordinator: ChatHistoryCoordinatorProtocol {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ChatHistoryViewController()
        let presenter = ChatHistoryPresenter(
            userId: "ApphudUserID",
            appId: "com.test.test"
        )
        
        viewController.presenter = presenter
        viewController.coordinator = self
        presenter.view = viewController
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - ChatHistoryCoordinatorProtocol
    
    func didTapBack() {
        navigationController.popViewController(animated: true)
    }
}
