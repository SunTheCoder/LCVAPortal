import SwiftUI
import AVKit
import ObjectiveC

struct VideoPreviewView: UIViewControllerRepresentable {
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
        
        playerViewController.showsPlaybackControls = false
        return playerViewController
    }
    
    private func setupPlayer(_ player: AVPlayer, for controller: AVPlayerViewController) {
        // Create a new player item from the asset
        guard let asset = player.currentItem?.asset else { return }
        let playerItem = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        queuePlayer.isMuted = true
        queuePlayer.play()
        
        controller.player = queuePlayer
        
        // Store reference to prevent deallocation
        controller.looper = playerLooper
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

// Helper to store strong reference to looper
private class LooperHolder {
    var looper: AVPlayerLooper?
}

private var looperKey: UInt8 = 0

extension AVPlayerViewController {
    var looper: AVPlayerLooper? {
        get {
            return (objc_getAssociatedObject(self, &looperKey) as? LooperHolder)?.looper
        }
        set {
            if objc_getAssociatedObject(self, &looperKey) == nil {
                objc_setAssociatedObject(
                    self,
                    &looperKey,
                    LooperHolder(),
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
            (objc_getAssociatedObject(self, &looperKey) as? LooperHolder)?.looper = newValue
        }
    }
} 