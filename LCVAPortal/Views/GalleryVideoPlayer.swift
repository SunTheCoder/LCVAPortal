import SwiftUI
import AVKit

struct GalleryVideoPlayer: UIViewControllerRepresentable {
    let urlString: String
    let filename: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        
        // Style the video view
        playerViewController.view.layer.cornerRadius = 12
        playerViewController.view.layer.masksToBounds = true
        
        // Try to get cached video first
        if let player = VideoCache.shared.getCachedVideo(urlString: urlString, filename: filename) {
            setupPlayer(player, for: playerViewController)
        } else {
            // Cache miss - download and setup
            Task {
                do {
                    guard let url = URL(string: urlString) else { return }
                    try await VideoCache.shared.cacheVideo(from: url, filename: filename)
                    if let player = VideoCache.shared.getCachedVideo(urlString: urlString, filename: filename) {
                        await MainActor.run {
                            setupPlayer(player, for: playerViewController)
                        }
                    }
                } catch {
                    print("❌ Failed to cache video: \(error)")
                }
            }
        }
        
        // Show controls for gallery view
        playerViewController.showsPlaybackControls = true
        return playerViewController
    }
    
    private func setupPlayer(_ player: AVPlayer, for controller: AVPlayerViewController) {
        // Create new player item to avoid sharing state
        guard let asset = player.currentItem?.asset else { return }
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        // Gallery mode: Audio on, manual control
        player.isMuted = false
        player.actionAtItemEnd = .pause
        
        controller.player = player
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
} 