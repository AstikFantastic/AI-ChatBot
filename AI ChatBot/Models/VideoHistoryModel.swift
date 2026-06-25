import UIKit

struct VideoHistoryItem {
    let id: String
    let thumbnailURL: String?
    let thumbnail: UIImage?
    let template: VideoTemplate
    let createdAt: Date
    let status: GenerationStatus
    
    enum GenerationStatus {
        case completed
        case processing
        case failed
    }
}
