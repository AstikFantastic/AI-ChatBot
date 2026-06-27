import Foundation

// MARK: - Templates Coordinator Protocol

protocol TemplatesCoordinatorProtocol: AnyObject {
    func showTemplateDetails(_ template: VideoTemplate, allTemplates: [VideoTemplate], currentIndex: Int)
    func showVideoHistory()
    func showPaywall()
}

// MARK: - Template Details Coordinator Protocol

protocol TemplateDetailsCoordinatorProtocol: AnyObject {
    func navigateToProcessing(imageData: Data, template: VideoTemplate)
}

// MARK: - Video Processing Coordinator Protocol

protocol VideoProcessingCoordinatorProtocol: AnyObject {
    func dismissProcessing()
}
// MARK: - Video History Coordinator Protocol

protocol VideoHistoryCoordinatorProtocol: AnyObject {
    func dismissHistory()
}

// MARK: - Chat Coordinator Protocol

protocol ChatCoordinatorProtocol: AnyObject {
    func didTapBack()
    func didTapHistory()
}

