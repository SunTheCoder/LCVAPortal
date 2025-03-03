import SwiftUI

struct CachedImageView: View {
    let urlString: String
    let filename: String
    @State private var image: UIImage?
    private let id = UUID().uuidString.prefix(6)
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView() // Loading indicator
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    private func loadImage() {
        print("🖼️ [\(id)] Loading image: \(filename)")
        if ImageCache.shared.imageExists(filename: filename) {
            // Load from disk cache
            image = ImageCache.shared.loadImageFromDisk(filename: filename)
        } else {
            print("📥 [\(id)] Downloading image: \(urlString)")
            downloadImage()
        }
    }
    
    private func downloadImage() {
        guard let url = URL(string: urlString) else {
            print("❌ [\(id)] Invalid URL: \(urlString)")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let downloadedImage = UIImage(data: data) {
                    print("✅ [\(id)] Downloaded image: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                    await MainActor.run {
                        self.image = downloadedImage
                    }
                    ImageCache.shared.saveImageToDisk(image: downloadedImage, filename: filename)
                }
            } catch {
                print("❌ [\(id)] Failed to download image:", error)
            }
        }
    }
} 