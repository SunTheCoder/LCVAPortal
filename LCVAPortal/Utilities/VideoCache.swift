import Foundation
import AVKit

class VideoCache {
    static let shared = VideoCache()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var memoryCache: [String: AVPlayer] = [:]
    private var activeDownloads: [String: Task<Void, Error>] = [:]
    
    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDirectory.appendingPathComponent("video_cache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("📁 Video cache directory: \(cacheDirectory.path)")
    }
    
    func cacheVideo(from url: URL, filename: String) async throws {
        print("📝 Caching video: \(filename)")
        
        let cacheUrl = cacheDirectory.appendingPathComponent(filename)
        
        // Check if already cached
        if fileManager.fileExists(atPath: cacheUrl.path) {
            print("✅ Video already cached")
            return
        }
        
        // Check if already downloading
        if let existingTask = activeDownloads[filename] {
            print("⏳ Waiting for existing download...")
            try await existingTask.value
            return
        }
        
        // Start new download
        let task = Task {
            let (downloadUrl, _) = try await URLSession.shared.download(from: url)
            try fileManager.moveItem(at: downloadUrl, to: cacheUrl)
            print("💾 Video cached to disk: \(filename)")
            activeDownloads.removeValue(forKey: filename)
        }
        
        activeDownloads[filename] = task
        try await task.value
    }
    
    func getCachedVideo(urlString: String, filename: String) -> AVPlayer? {
        // Check memory cache
        if let player = memoryCache[urlString] {
            print("💭 Memory cache hit for video: \(filename)")
            return player
        }
        
        // Check disk cache
        let cacheUrl = cacheDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: cacheUrl.path) {
            print("💾 Disk cache hit for video: \(filename)")
            let player = AVPlayer(url: cacheUrl)
            player.automaticallyWaitsToMinimizeStalling = true
            memoryCache[urlString] = player
            return player
        }
        
        print("❌ Cache miss for video: \(filename)")
        return nil
    }
    
    func clearCache() {
        print("🧹 Clearing video cache")
        memoryCache.removeAll()
        activeDownloads.values.forEach { $0.cancel() }
        activeDownloads.removeAll()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
} 