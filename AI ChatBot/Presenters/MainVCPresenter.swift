import UIKit

protocol MainViewProtocol: AnyObject {
    func showTitle(_ text: String)
}

final class MainVCPresenter {
    weak var view: MainViewProtocol?
    private let coordinator: AppCoordinatorProtocol
    
    init(coordinator: AppCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        
    }
    
    func didTapAskbutton() {
        coordinator.openChatVC()
    }
    
    func didTapVideoButton() {
        coordinator.openVideoVC()
    }
    
    func didTapSettings() {
        coordinator.showPaywall()
    }
    
    func didTapVideoCard() {
        let hasPremium = PurchaseManager.shared.hasPremium
        
        if hasPremium {
            coordinator.openVideoVC()
        } else {
            coordinator.showPaywall()
        }
    }
}
