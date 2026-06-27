import UIKit

protocol AppCoordinatorProtocol: AnyObject {
    func openChatVC()
    func openVideoVC()
    func openVideoHistory()
    func showPaywall()
}

final class Coordinator: AppCoordinatorProtocol, TemplatesCoordinatorProtocol, TemplateDetailsCoordinatorProtocol, VideoProcessingCoordinatorProtocol, VideoHistoryCoordinatorProtocol, PayWallCoordinatorProtocol {
    
    let navigationController: UINavigationController
    private var childCoordinators: [Any] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let presenter = MainVCPresenter(coordinator: self)
        let vc = MainViewController(presenter: presenter)
        presenter.view = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openChatVC() {
        let chatCoordinator = ChatCoordinator(navigationController: navigationController)
        childCoordinators.append(chatCoordinator)
        chatCoordinator.start()
    }
    
    func openVideoVC() {
        let apiClient = PixverseAPIClient(bearerToken: AppConfig.pixverseBearerToken)
        let presenter = TemplatesPresenter(
            coordinator: self,
            apiClient: apiClient,
            applicationId: AppConfig.applicationId
        )
        let videoVC = TemplatesViewController(presenter: presenter)
        presenter.view = videoVC
        navigationController.pushViewController(videoVC, animated: true)
    }
    
    func openVideoHistory() {
        let presenter = VideoHistoryPresenter(coordinator: self)
        let historyVC = VideoHistoryViewController(presenter: presenter)
        presenter.view = historyVC
        navigationController.pushViewController(historyVC, animated: true)
    }
    
    // MARK: - TemplatesCoordinatorProtocol
    
    func showTemplateDetails(_ template: VideoTemplate, allTemplates: [VideoTemplate], currentIndex: Int) {
        let presenter = TemplateDetailsPresenter(
            template: template,
            allTemplates: allTemplates,
            currentIndex: currentIndex,
            coordinator: self
        )
        let detailsVC = TemplateDetailsViewController(presenter: presenter)
        presenter.view = detailsVC
        
        navigationController.pushViewController(detailsVC, animated: true)
    }
    
    func showVideoHistory() {
        openVideoHistory()
    }
    
    // MARK: - TemplateDetailsCoordinatorProtocol
    
    func navigateToProcessing(imageData: Data, template: VideoTemplate) {
        let presenter = VideoProcessingPresenter(imageData: imageData,
                                                 template: template,
                                                 coordinator: self
        )
        let processingVC = VideoProcessingViewController(presenter: presenter)
        presenter.view = processingVC
        
        navigationController.pushViewController(processingVC, animated: true)
    }
    
    // MARK: - VideoProcessingCoordinatorProtocol
    
    func dismissProcessing() {
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - VideoHistoryCoordinatorProtocol
    
    func dismissHistory() {
        navigationController.popViewController(animated: true)
    }
    
    
    // MARK: - PayWallCoordinatorProtocol
    
    func showPaywall() {
        let presenter = PayWallPresenter(coordinator: self)
        let paywallVC = PayWallVC(presenter: presenter)
        presenter.view = paywallVC
        
        paywallVC.modalPresentationStyle = .fullScreen
        navigationController.present(paywallVC, animated: true)
    }
    
    func dismissPaywall() {
        navigationController.dismiss(animated: true)
    }
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://your-privacy-policy-url.com") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTermsOfUse() {
        if let url = URL(string: "https://your-terms-url.com") {
            UIApplication.shared.open(url)
        }
    }
}
