import Foundation
import Photos

final class TemplatesPresenter: TemplatesPresenterProtocol {

    weak var view: TemplatesViewProtocol?

    private weak var coordinator: TemplatesCoordinatorProtocol?
    private let apiClient: PixverseAPIClientProtocol
    private let applicationId: String
    private var task: Task<Void, Never>?

    private var allTemplates: [VideoTemplate] = []
    private var selectedCategory: String?

    init(
        coordinator: TemplatesCoordinatorProtocol,
        apiClient: PixverseAPIClientProtocol,
        applicationId: String
    ) {
        self.coordinator = coordinator
        self.apiClient = apiClient
        self.applicationId = applicationId
    }

    func viewDidLoad() {
        loadTemplates()
    }

    func didPullToRefresh() {
        loadTemplates()
    }

    func didSelectTemplate(_ template: VideoTemplate, fromFilteredList: [VideoTemplate], atIndex: Int) {
        guard PurchaseManager.shared.hasPremium else {
            coordinator?.showPaywall()
            return
        }
        
        checkPhotoLibraryPermission(template: template, fromFilteredList: fromFilteredList, atIndex: atIndex)
    }
    
    func didSelectCategory(_ category: String) {
        if selectedCategory == category {
            selectedCategory = nil
            view?.updateFilteredTemplates(allTemplates)
        } else {
            selectedCategory = category
            let filtered: [VideoTemplate]
            if category == "Popular" {
                filtered = allTemplates
            } else {
                filtered = allTemplates.filter { $0.category == category }
            }
            view?.updateFilteredTemplates(filtered)
        }
    }
    
    func didTapHistoryButton() {
        coordinator?.showVideoHistory()
    }
    
    func didTapBackButton() {
        view?.navigateBack()
    }
    
    private func checkPhotoLibraryPermission(template: VideoTemplate, fromFilteredList: [VideoTemplate], atIndex: Int) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            coordinator?.showTemplateDetails(template, allTemplates: fromFilteredList, currentIndex: atIndex)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        self?.coordinator?.showTemplateDetails(template, allTemplates: fromFilteredList, currentIndex: atIndex)
                    default:
                        self?.view?.showPhotoPermissionAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            view?.showPhotoPermissionAlert()
            
        @unknown default:
            view?.showPhotoPermissionAlert()
        }
    }

    private func loadTemplates() {
        task?.cancel()
        view?.showLoading()

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.apiClient.getTemplates(applicationId: self.applicationId)

                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                if let jsonData = try? encoder.encode(response),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
                
                self.allTemplates = response.templates
                let uniqueCategories = Set(response.templates.map { $0.category })
                let categories = ["Popular"] + uniqueCategories.sorted()
                
                self.view?.showCategories(categories)
                self.view?.showTemplates(response.templates)
            } catch {
                self.view?.showError(error.localizedDescription)
            }
        }
    }

    deinit {
        task?.cancel()
    }
}
