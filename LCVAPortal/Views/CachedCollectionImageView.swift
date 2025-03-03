import SwiftUI

// For the main grid display
struct CachedCollectionImageView: View {
    let urlString: String
    let filename: String
    @State private var image: UIImage?
    private let id = UUID().uuidString.prefix(6)
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    // ... same loading logic as CachedImageView ...
    private func loadImage() {
        print("🖼️ [\(id)] Loading collection image: \(filename)")
        if ImageCache.shared.imageExists(filename: filename) {
            image = ImageCache.shared.loadImageFromDisk(filename: filename)
        } else {
            print("📥 [\(id)] Downloading collection image: \(urlString)")
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
                    print("✅ [\(id)] Downloaded collection image: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
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

// For thumbnails in lists
struct CachedCollectionThumbView: View {
    let urlString: String
    let filename: String
    let size: CGFloat
    @State private var image: UIImage?
    private let id = UUID().uuidString.prefix(6)
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                ProgressView()
                    .frame(width: size, height: size)
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    // ... same loading logic as above ...
    private func loadImage() {
        print("🖼️ [\(id)] Loading thumbnail: \(filename)")
        if ImageCache.shared.imageExists(filename: filename) {
            image = ImageCache.shared.loadImageFromDisk(filename: filename)
        } else {
            print("📥 [\(id)] Downloading thumbnail: \(urlString)")
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
                    print("✅ [\(id)] Downloaded thumbnail: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
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