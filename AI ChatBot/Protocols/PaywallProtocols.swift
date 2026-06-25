import UIKit

protocol PayWallViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func updateYearOption(title: String, price: String, badge: String?)
    func updateMonthOption(title: String, price: String)
    func showError(title: String, message: String)
    func showSuccess(title: String, message: String, completion: (() -> Void)?)
    func dismissView()
}

protocol PayWallPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectYearOption()
    func didSelectMonthOption()
    func didTapUnlockNow()
    func didTapRestore()
    func didTapPrivacy()
    func didTapTerms()
    func didTapClose()
}

protocol PayWallCoordinatorProtocol: AnyObject {
    func dismissPaywall()
    func openPrivacyPolicy()
    func openTermsOfUse()
}
