import UIKit
import Photos

final class TemplateDetailsPresenter: TemplateDetailsPresenterProtocol {
    
    weak var view: TemplateDetailsViewProtocol?
    weak var coordinator: TemplateDetailsCoordinatorProtocol?
    
    private var allTemplates: [VideoTemplate]
    private var currentIndex: Int
    private var selectedImage: UIImage?
    
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
        view?.updatePhotoPreview(image)
        view?.enableCreateButton()
        view?.showRemovePhotoButton()
    }
    
    func didTapRemovePhoto() {
        selectedImage = nil
        view?.clearPhotoPreview()
        view?.disableCreateButton()
        view?.hideRemovePhotoButton()
    }
    
    func didTapCreate(format: String, quality: String) {
        guard let image = selectedImage else {
            return
        }
        
        generateVideo(with: image, format: format, quality: quality)
    }
    
    private func generateVideo(with image: UIImage, format: String, quality: String) {
        view?.showLoading()
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            do {
                let taskId = try await self.generateVideoRequest(
                    templateId: self.currentTemplate.templateId,
                    image: image
                )
                self.view?.hideLoading()
                self.coordinator?.navigateToProcessing(taskId: taskId, template: self.currentTemplate)
                
            } catch {
                self.view?.hideLoading()
                self.view?.showError(error.localizedDescription)
            }
        }
    }
    
    private func generateVideoRequest(templateId: Int, image: UIImage) async throws -> String {
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
        
        let processedImage = resizeAndCompressImage(image, maxSizeKB: 800)
        if let imageData = processedImage {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        } else {
            throw APIError.invalidResponse
        }
        
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
            let videoIdString = String(videoId)
            return videoIdString
        }
        
        if let videoId = json["video_id"] as? String {
            return videoId
        }
 
        throw APIError.invalidResponse
    }
    
    // MARK: - Image Processing
    
    private func resizeAndCompressImage(_ image: UIImage, maxSizeKB: Int) -> Data? {
        let maxBytes = maxSizeKB * 1024
        
        var currentImage = image
        let maxDimension: CGFloat = 1920
        
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = maxDimension / max(image.size.width, image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            currentImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }

        var compression: CGFloat = 0.8
        var imageData = currentImage.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = currentImage.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}
