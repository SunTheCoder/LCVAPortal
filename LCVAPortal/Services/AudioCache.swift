import Foundation
import AVFoundation

class AudioCache {
    static let shared = AudioCache()
    private var cache: [String: AVPlayer] = [:]
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachePath.appendingPathComponent("audio_cache")
        
        try? fileManager.createDirectory(at: cacheDirectory, 
                                       withIntermediateDirectories: true)
        print("📁 Audio cache directory: \(cacheDirectory.path)")
    }
    
    func getAudio(for url: URL) async -> AVPlayer? {
        let filename = url.lastPathComponent
        
        // Check memory cache first
        if let player = cache[url.absoluteString] {
            print("💭 Memory cache hit for audio: \(filename)")
            return player
        }
        
        // Check disk cache
        let cachedFile = cacheDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: cachedFile.path) {
            print("💾 Disk cache hit for audio: \(filename)")
            let player = AVPlayer(url: cachedFile)
            cache[url.absoluteString] = player
            return player
        }
        
        // Download and cache
        print("📥 Downloading audio: \(filename)")
        do {
            let (downloadedUrl, _) = try await URLSession.shared.download(from: url)
            try fileManager.moveItem(at: downloadedUrl, to: cachedFile)
            
            let player = AVPlayer(url: cachedFile)
            cache[url.absoluteString] = player
            print("✅ Audio cached successfully: \(filename)")
            return player
        } catch {
            print("❌ Failed to cache audio: \(error)")
            return nil
        }
    }
} 