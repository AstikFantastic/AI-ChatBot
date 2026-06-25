import UIKit
import Photos

final class VideoProcessingPresenter: VideoProcessingPresenterProtocol {
    
    weak var view: VideoProcessingViewProtocol?
    weak var coordinator: VideoProcessingCoordinatorProtocol?
    
    private let taskId: String
    private let template: VideoTemplate
    private let videoHistoryManager: VideoHistoryManager
    
    init(
        taskId: String,
        template: VideoTemplate,
        coordinator: VideoProcessingCoordinatorProtocol,
        videoHistoryManager: VideoHistoryManager = .shared
    ) {
        self.taskId = taskId
        self.template = template
        self.coordinator = coordinator
        self.videoHistoryManager = videoHistoryManager
    }
    
    // MARK: - VideoProcessingPresenterProtocol
    
    func viewDidLoad() {
        view?.setTitle(template.name)
        startGeneration()
    }
    
    func didTapBack() {
        coordinator?.dismissProcessing()
    }
    
    func didTapReplace() {
        startGeneration()
    }
    
    func didTapDownload(image: UIImage) {
        requestPhotoLibraryPermissionAndSave(image: image)
    }
    
    // MARK: - Methods
    
    private func startGeneration() {
        view?.showLoading(
            status: "Generating...",
            message: "We're creating the best result for you"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.handleGenerationComplete()
        }
    }
    
    private func handleGenerationComplete() {
        if let resultImage = UIImage(named: "Result") {
            view?.hideLoading()
            view?.showResult(image: resultImage)
            videoHistoryManager.saveHistoryItem(template: template, thumbnail: resultImage)
        } else {
            view?.hideLoading()
            view?.showError("Failed to generate video")
        }
    }
    
    private func requestPhotoLibraryPermissionAndSave(image: UIImage) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            saveImageToPhotos(image)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.saveImageToPhotos(image)
                    } else {
                        self?.view?.showError("Photo library access denied")
                    }
                }
            }
            
        case .denied, .restricted:
            view?.showError("Please allow photo library access in Settings")
            
        @unknown default:
            view?.showError("Unknown authorization status")
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError("Failed to save image: \(error.localizedDescription)")
                } else if success {
                    self?.view?.showSuccessBanner(message: "Video has been saved\nto your gallery")
                } else {
                    self?.view?.showError("Failed to save image")
                }
            }
        }
    }
}
