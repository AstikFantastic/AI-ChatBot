import UIKit

protocol VideoProcessingViewProtocol: AnyObject {
    func setTitle(_ title: String)
    func showLoading(status: String, message: String)
    func hideLoading()
    func showResult(image: UIImage)
    func showError(_ message: String)
    func showSuccessBanner(message: String)
}

protocol VideoProcessingPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapBack()
    func didTapReplace()
    func didTapDownload(image: UIImage)
}
