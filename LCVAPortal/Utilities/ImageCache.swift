import SwiftUI
import WebKit

class ImageCache {
    static let shared = ImageCache() // Singleton instance
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var memoryCache = NSCache<NSString, UIImage>()
    
    private init() {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        // Configure memory cache
        memoryCache.countLimit = 100 // Max number of images
        memoryCache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        print("📁 Cache directory: \(cacheDirectory.path)")
    }
    
    func saveImageToDisk(image: UIImage, filename: String) {
        let url = cacheDirectory.appendingPathComponent(filename)
        
        // Check if it's a WebP image
        if filename.hasSuffix(".webp"),
           let data = image.pngData() { // Keep WebP as-is
            do {
                try data.write(to: url)
                // Also cache in memory
                memoryCache.setObject(image, forKey: filename as NSString)
                print("💾 Saved WebP image to cache: \(filename) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))")
            } catch {
                print("❌ Error saving image:", error)
            }
        } else {
            // For non-WebP images, use JPEG compression
            if let data = image.jpegData(compressionQuality: 0.8) {
                do {
                    try data.write(to: url)
                    memoryCache.setObject(image, forKey: filename as NSString)
                    print("💾 Saved JPEG image to cache: \(filename) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))")
                } catch {
                    print("❌ Error saving image:", error)
                }
            }
        }
    }
    
    func loadImageFromDisk(filename: String) -> UIImage? {
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: filename as NSString) {
            print("💭 Memory cache hit: \(filename)")
            return cachedImage
        }
        
        let url = cacheDirectory.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            // Cache in memory for next time
            memoryCache.setObject(image, forKey: filename as NSString)
            print("🔄 Loaded cached image: \(filename) (\(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)))")
            return image
        }
        print("⚠️ Cache miss for: \(filename)")
        return nil
    }
    
    func imageExists(filename: String) -> Bool {
        // Check memory cache first
        if memoryCache.object(forKey: filename as NSString) != nil {
            print("💭 Memory cache hit: \(filename)")
            return true
        }
        
        let url = cacheDirectory.appendingPathComponent(filename)
        let exists = fileManager.fileExists(atPath: url.path)
        print(exists ? "✅ Cache hit: \(filename)" : "❌ Cache miss: \(filename)")
        return exists
    }
    
    func clearCache() {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for url in contents {
                try fileManager.removeItem(at: url)
            }
            print("🧹 Cleared image cache")
        } catch {
            print("❌ Error clearing cache:", error)
        }
    }
    
    // Helper to get cache size
    func getCacheSize() -> Int64 {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            return try contents.reduce(Int64(0)) { 
                $0 + Int64(try $1.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0)
            }
        } catch {
            print("❌ Error getting cache size:", error)
            return 0
        }
    }
} 