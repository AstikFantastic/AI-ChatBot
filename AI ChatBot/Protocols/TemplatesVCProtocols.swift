import Foundation

protocol TemplatesViewProtocol: AnyObject {
    func showLoading()
    func showTemplates(_ templates: [VideoTemplate])
    func showCategories(_ categories: [String])
    func updateFilteredTemplates(_ templates: [VideoTemplate])
    func showError(_ message: String)
    func showPhotoPermissionAlert()
    func navigateBack()
}

protocol TemplatesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTemplate(_ template: VideoTemplate, fromFilteredList: [VideoTemplate], atIndex: Int)
    func didPullToRefresh()
    func didSelectCategory(_ category: String)
    func didTapHistoryButton()
    func didTapBackButton()
}

