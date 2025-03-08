import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioUrl: URL
    let title: String
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: geometry.size.width * CGFloat(progress / max(duration, 1)), height: 2)
                }
                .cornerRadius(1)
                .contentShape(Rectangle())
                .padding(.vertical, 15)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let percentage = value.location.x / geometry.size.width
                            let time = duration * Double(percentage)
                            player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
                        }
                )
            }
            .frame(height: 32)
            
            Text(formatTime(progress))
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 45, alignment: .trailing)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(4)
        .onAppear {
            loadAudio()
        }
        .onDisappear {
            player?.pause()
            isPlaying = false
        }
        .onReceive(timer) { _ in
            updateProgress()
        }
    }
    
    private func loadAudio() {
        Task {
            player = await AudioCache.shared.getAudio(for: audioUrl)
            if let player = player {
                if let duration = try? await player.currentItem?.asset.load(.duration) {
                    let durationInSeconds = CMTimeGetSeconds(duration)
                    if !durationInSeconds.isNaN && !durationInSeconds.isInfinite {
                        self.duration = durationInSeconds
                    }
                }
            }
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    private func updateProgress() {
        guard let player = player else { return }
        let currentTime = player.currentTime().seconds
        if !currentTime.isNaN && !currentTime.isInfinite {
            progress = currentTime
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite && seconds >= 0 else {
            return "0:00"
        }
        
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
} 
