import UIKit
import Photos

final class TemplateDetailsPresenter: TemplateDetailsPresenterProtocol {
    
    weak var view: TemplateDetailsViewProtocol?
    weak var coordinator: TemplateDetailsCoordinatorProtocol?
    
    private var allTemplates: [VideoTemplate]
    private var currentIndex: Int
    private var selectedImage: UIImage?
    private var selectedImageData: Data?
    
    var templatesCount: Int {
        return allTemplates.count
    }
    
    init(template: VideoTemplate, allTemplates: [VideoTemplate], currentIndex: Int, coordinator: TemplateDetailsCoordinatorProtocol) {
        self.allTemplates = allTemplates
        self.currentIndex = currentIndex
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.updateTitle(currentTemplate.name)
        view?.reloadCarousel()
    }
    
    private var currentTemplate: VideoTemplate {
        return allTemplates[currentIndex]
    }
    
    func didScrollToTemplate(at index: Int) {
        guard index >= 0, index < allTemplates.count, index != currentIndex else { return }
        currentIndex = index
        view?.updateTitle(currentTemplate.name)
    }
    
    func templateAt(index: Int) -> VideoTemplate {
        return allTemplates[index]
    }
    
    func currentTemplateIndex() -> Int {
        return currentIndex
    }
    
    func didTapAddPhoto() {
        view?.showPhotoPicker()
    }
    
    func didSelectPhoto(_ image: UIImage) {
        selectedImage = image
        selectedImageData = nil
        
        view?.updatePhotoPreview(image)
        view?.enableCreateButton()
        view?.showRemovePhotoButton()
        
        Task { [weak self] in
            let imageData = await Task.detached {
                image.jpegData(compressionQuality: 1.0)
            }.value
            self?.selectedImageData = imageData
        }
    }
    
    func didTapRemovePhoto() {
        selectedImage = nil
        selectedImageData = nil
        view?.clearPhotoPreview()
        view?.disableCreateButton()
        view?.hideRemovePhotoButton()
    }
    
    func didTapCreate(format: String, quality: String) {
        guard let image = selectedImage else { return }

        guard let imageData = selectedImageData ?? image.jpegData(compressionQuality: 1.0) else {
            view?.showError("Failed to process image")
            return
        }

        coordinator?.navigateToProcessing(imageData: imageData, template: currentTemplate)
    }
}
