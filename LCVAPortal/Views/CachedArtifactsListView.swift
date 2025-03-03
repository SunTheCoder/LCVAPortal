import SwiftUI

struct CachedArtifactsListView: View {
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
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                ProgressView()
                    .frame(width: 60, height: 60)
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    // Same loading logic as above but with different logging messages
    private func loadImage() {
        print("🖼️ [\(id)] Loading list artifact: \(filename)")
        if ImageCache.shared.imageExists(filename: filename) {
            image = ImageCache.shared.loadImageFromDisk(filename: filename)
        } else {
            print("📥 [\(id)] Downloading list artifact: \(urlString)")
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
                    print("✅ [\(id)] Downloaded list artifact: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
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