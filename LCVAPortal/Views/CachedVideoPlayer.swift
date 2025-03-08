import SwiftUI
import AVKit

struct CachedVideoPlayer: View {
    let urlString: String
    let filename: String
    var autoPlay: Bool = false  // Default to false for thumbnails
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 150)
                    .cornerRadius(4)
                    .onDisappear {
                        player.pause()
                    }
                    .onAppear {
                        if autoPlay {
                            player.play()
                        }
                    }
            } else if isLoading {
                ProgressView()
                    .frame(height: 150)
            } else {
                Image(systemName: "video.slash")
                    .foregroundColor(.red)
                    .frame(height: 150)
                    .overlay {
                        if let error = error {
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(4)
                        }
                    }
            }
        }
        .task {
            do {
                // Try cache first
                if let cachedPlayer = VideoCache.shared.getCachedVideo(
                    urlString: urlString,
                    filename: filename
                ) {
                    player = cachedPlayer
                    if autoPlay {
                        player?.play()
                    }
                    isLoading = false
                    return
                }
                
                // Cache miss - download and cache
                guard let url = URL(string: urlString) else {
                    isLoading = false
                    return
                }
                
                try await VideoCache.shared.cacheVideo(from: url, filename: filename)
                player = VideoCache.shared.getCachedVideo(urlString: urlString, filename: filename)
                if autoPlay {
                    player?.play()
                }
            } catch {
                print("❌ Failed to cache video: \(error)")
                self.error = error
            }
            isLoading = false
        }
    }
} 
