import UIKit
import Photos

@MainActor
final class VideoProcessingPresenter: VideoProcessingPresenterProtocol {
    
    weak var view: VideoProcessingViewProtocol?
    weak var coordinator: VideoProcessingCoordinatorProtocol?
    
    private let imageData: Data
    private let template: VideoTemplate
    private let videoHistoryManager: VideoHistoryManager

    init(
        imageData: Data,
        template: VideoTemplate,
        coordinator: VideoProcessingCoordinatorProtocol,
        videoHistoryManager: VideoHistoryManager? = nil
    ) {
        self.imageData = imageData
        self.template = template
        self.coordinator = coordinator
        self.videoHistoryManager = videoHistoryManager ?? .shared
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

        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.generateVideoRequest(
                    templateId: self.template.templateId,
                    imageData: self.imageData
                )

                self.handleGenerationComplete()
            } catch {
                self.view?.hideLoading()
                self.view?.showError(error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.coordinator?.dismissProcessing()
                }
            }
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
    
    private func generateVideoRequest(templateId: Int, imageData: Data) async throws -> String {
        var components = URLComponents(string: "https://nebulaapps.site/pixverse/api/v1/template2video")!
        components.queryItems = [
            URLQueryItem(name: "user_id", value: AppConfig.userId),
            URLQueryItem(name: "app_id", value: AppConfig.appId)
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue("Bearer \(AppConfig.pixverseBearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"template_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(templateId)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["error"] as? String ?? errorJson["message"] as? String {
                print(errorMessage)
                throw APIError.server(statusCode: httpResponse.statusCode, data: data)
            }
            throw APIError.server(statusCode: httpResponse.statusCode, data: data)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidResponse
        }

        if let videoId = json["video_id"] as? Int {
            return String(videoId)
        }

        if let videoId = json["video_id"] as? String {
            return videoId
        }

        throw APIError.invalidResponse
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
