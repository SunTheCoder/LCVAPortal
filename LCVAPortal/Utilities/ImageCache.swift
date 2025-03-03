import SwiftUI

class ImageCache {
    static let shared = ImageCache() // Singleton instance
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        print("📁 Cache directory: \(cacheDirectory.path)")
    }
    
    func saveImageToDisk(image: UIImage, filename: String) {
        let url = cacheDirectory.appendingPathComponent(filename)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: url)
                print("💾 Saved image to cache: \(filename) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))")
            } catch {
                print("❌ Error saving image:", error)
            }
        }
    }
    
    func loadImageFromDisk(filename: String) -> UIImage? {
        let url = cacheDirectory.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            print("🔄 Loaded cached image: \(filename) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))")
            return image
        }
        print("⚠️ Cache miss for: \(filename)")
        return nil
    }
    
    func imageExists(filename: String) -> Bool {
        let url = cacheDirectory.appendingPathComponent(filename)
        let exists = fileManager.fileExists(atPath: url.path)
        print(exists ? "✅ Cache hit: \(filename)" : "❌ Cache miss: \(filename)")
        return exists
    }
} 