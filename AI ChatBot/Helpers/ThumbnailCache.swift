import UIKit
import AVFoundation

final class ThumbnailCache {
    
    static let shared = ThumbnailCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "com.app.thumbnailCache", qos: .userInitiated, attributes: .concurrent)
    
    private init() {
        
        cache.countLimit = 500
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    // MARK: - Methods
    
    func getThumbnail(for url: URL, maxSize: CGSize = CGSize(width: 400, height: 400), completion: @escaping (UIImage?) -> Void) {
        let cacheKey = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }

        queue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let thumbnail = self.generateThumbnail(from: url, maxSize: maxSize)
            
            if let thumbnail = thumbnail {
                self.cache.setObject(thumbnail, forKey: cacheKey)
            }
            
            DispatchQueue.main.async {
                completion(thumbnail)
            }
        }
    }
    
    private func generateThumbnail(from url: URL, maxSize: CGSize) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = maxSize
        
        let time = CMTime(seconds: 0.5, preferredTimescale: 600)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
