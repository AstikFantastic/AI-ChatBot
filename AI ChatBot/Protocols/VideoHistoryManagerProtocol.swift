import UIKit

protocol VideoHistoryManagerProtocol {

    func saveHistoryItem(template: VideoTemplate, thumbnail: UIImage?)
    
    func loadHistory() -> [VideoHistoryItem]
    
}
