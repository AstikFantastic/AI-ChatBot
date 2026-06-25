import UIKit

protocol TemplateDetailsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func updatePhotoPreview(_ image: UIImage)
    func clearPhotoPreview()
    func enableCreateButton()
    func disableCreateButton()
    func showPhotoPicker()
    func showRemovePhotoButton()
    func hideRemovePhotoButton()
    func showSuccess(_ message: String)
    func showError(_ message: String)
    func updateTitle(_ title: String)
    func reloadCarousel()
    func scrollToTemplate(at index: Int, animated: Bool)
}

protocol TemplateDetailsPresenterProtocol: AnyObject {
    var templatesCount: Int { get }
    
    func viewDidLoad()
    func didTapAddPhoto()
    func didSelectPhoto(_ image: UIImage)
    func didTapRemovePhoto()
    func didTapCreate(format: String, quality: String)
    func didScrollToTemplate(at index: Int)
    func templateAt(index: Int) -> VideoTemplate
    func currentTemplateIndex() -> Int
}
