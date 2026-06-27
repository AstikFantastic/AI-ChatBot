import UIKit

final class VideoHistoryManager: VideoHistoryManagerProtocol {

    static let shared = VideoHistoryManager()
    
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let historyKey = "video_generation_history"
    
    init(
        userDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
    }
    
    // MARK: - Methods
    
    func saveHistoryItem(template: VideoTemplate, thumbnail: UIImage?) {
        var history = loadHistory()
        
        let newItem = VideoHistoryItem(
            id: UUID().uuidString,
            thumbnailURL: nil,
            thumbnail: thumbnail,
            template: template,
            createdAt: Date(),
            status: .completed
        )
        
        history.insert(newItem, at: 0)
        
        if let thumbnail = thumbnail {
            saveThumbnail(thumbnail, for: newItem.id)
        }
        
        saveHistoryMetadata(history)
    }
    
    func loadHistory() -> [VideoHistoryItem] {
        guard let data = userDefaults.data(forKey: historyKey),
              let metadata = try? JSONDecoder().decode([HistoryItemMetadata].self, from: data) else {
            return []
        }
        
        return metadata.compactMap { meta in
            let thumbnail = loadThumbnail(for: meta.id)
            
            return VideoHistoryItem(
                id: meta.id,
                thumbnailURL: nil,
                thumbnail: thumbnail,
                template: meta.template,
                createdAt: meta.createdAt,
                status: meta.status
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveHistoryMetadata(_ history: [VideoHistoryItem]) {
        let metadata = history.map { item in
            HistoryItemMetadata(
                id: item.id,
                template: item.template,
                createdAt: item.createdAt,
                status: item.status
            )
        }
        
        if let data = try? JSONEncoder().encode(metadata) {
            userDefaults.set(data, forKey: historyKey)
        }
    }
    
    private func saveThumbnail(_ image: UIImage, for id: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let url = getThumbnailURL(for: id)
        try? data.write(to: url)
    }
    
    private func loadThumbnail(for id: String) -> UIImage? {
        let url = getThumbnailURL(for: id)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    private func getThumbnailURL(for id: String) -> URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("thumbnail_\(id).jpg")
    }
}

// MARK: - Metadata Model

private struct HistoryItemMetadata: Codable {
    let id: String
    let template: VideoTemplate
    let createdAt: Date
    let status: VideoHistoryItem.GenerationStatus
}

// MARK: - Make GenerationStatus Codable

extension VideoHistoryItem.GenerationStatus: Codable {
    enum CodingKeys: String, CodingKey {
        case completed, processing, failed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "completed": self = .completed
        case "processing": self = .processing
        case "failed": self = .failed
        default: self = .completed
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .completed: try container.encode("completed")
        case .processing: try container.encode("processing")
        case .failed: try container.encode("failed")
        }
    }
}
