import SwiftUI

@MainActor
class PreloadManager: ObservableObject {
    static let shared = PreloadManager()
    
    @Published var isLoading = true
    @Published var loadingProgress = 0.0
    @Published var error: String?
    
    private let artifactManager = ArtifactManager.shared
    private let exhibitionManager = ExhibitionManager.shared
    private let imageCache = ImageCache.shared
    
    private init() {}
    
    func preloadAllContent() async {
        print("🚀 Starting content preload...")
        isLoading = true
        loadingProgress = 0.0
        
        do {
            // 1. Load all artifacts
            try await preloadArtifacts()
            loadingProgress = 0.3
            
            // 2. Load all exhibitions
            try await preloadExhibitions()
            loadingProgress = 0.5
            
            // 3. Preload all images
            await preloadImages()
            loadingProgress = 1.0
            
            print("✅ All content preloaded successfully!")
            isLoading = false
            
        } catch {
            print("❌ Error during preload:", error)
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    private func preloadArtifacts() async throws {
        print("📦 Preloading artifacts...")
        await artifactManager.preloadArtifacts()
    }
    
    private func preloadExhibitions() async throws {
        print("🎨 Preloading exhibitions...")
        await exhibitionManager.preloadExhibitionData()
    }
    
    private func preloadImages() async {
        print("🖼️ Preloading images...")
        
        // Collect all image URLs that need caching
        var imageUrls: [(url: String, filename: String)] = []
        
        // Add artifact images
        for artifact in artifactManager.artifacts {
            if let imageUrl = artifact.image_url {
                imageUrls.append((
                    imageUrl,
                    "\(artifact.id)-grid.jpg"
                ))
                imageUrls.append((
                    imageUrl,
                    "\(artifact.id)-list.jpg"
                ))
            }
        }
        
        // Add exhibition images
        for exhibition in exhibitionManager.exhibitionData {
            if let imageUrl = exhibition.exhibitions.image_url {
                imageUrls.append((
                    imageUrl,
                    "\(exhibition.exhibitions.id)-thumb.jpg"
                ))
            }
        }
        
        // Preload images in parallel with progress tracking
        let total = Double(imageUrls.count)
        var completed = 0.0
        
        await withTaskGroup(of: Void.self) { group in
            for (url, filename) in imageUrls {
                group.addTask {
                    if !ImageCache.shared.imageExists(filename: filename) {
                        if let image = await self.downloadImage(from: url) {
                            ImageCache.shared.saveImageToDisk(image: image, filename: filename)
                        }
                    }
                    await self.updateProgress(completed: completed + 1, total: total)
                    completed += 1
                }
            }
        }
    }
    
    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("❌ Failed to download image:", error)
            return nil
        }
    }
    
    private func updateProgress(completed: Double, total: Double) async {
        let base = 0.5 // Start after artifact and exhibition loading
        let imageProgress = completed / total * 0.5 // Images are the remaining 50%
        loadingProgress = base + imageProgress
    }
} 