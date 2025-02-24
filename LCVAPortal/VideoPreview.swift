import SwiftUI
import AVKit

struct VideoPreview: View {
    let videoName: String
    let title: String
    let subtitle: String
    
    @State private var player: AVPlayer?
    
    var body: some View {
        // Remove the outer VStack since we just want the video container
        ZStack {
            if let player = player {
                GeometryReader { geometry in
                    PlayerView(player: player)
                        .frame(
                            width: geometry.size.width + 50,  // Make video wider than container
                            height: geometry.size.height + 50  // Make video taller than container
                        )
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        print("Setting up player for video: \(videoName)")
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ Failed to find video file: \(videoName).mp4")
            return
        }
        print("✅ Found video file at: \(url)")
        
        let player = AVPlayer(url: url)
        player.isMuted = true
        player.actionAtItemEnd = .none
        
        // Add observer for playback status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            print("Video reached end, looping...")
            player.seek(to: .zero)
            player.play()
        }
        
        self.player = player
        print("Starting playback...")
        player.play()
    }
}

// Update PlayerView to ensure video fills space
private struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.player = player
        view.backgroundColor = .clear
        view.playerLayer.videoGravity = .resizeAspectFill  // This ensures filling
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.frame = uiView.bounds.insetBy(dx: -25, dy: -25)  // Extend beyond bounds
    }
}

// Custom UIView for AVPlayer
private class PlayerUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds  // Make sure layer fills the entire view
    }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { 
            playerLayer.player = newValue
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = bounds
        }
    }
} 