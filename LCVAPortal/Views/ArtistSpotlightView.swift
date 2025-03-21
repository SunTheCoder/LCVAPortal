import SwiftUI

struct ArtistSpotlightView: View {
    @StateObject private var viewModel = SpotlightViewModel()
    @State private var slideInOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var backgroundScale: CGFloat = 1.0
    
    var body: some View {
        Group {
            if let artist = viewModel.currentArtist {
                NavigationLink(destination: SpotlightGalleryView(
                    artist: artist,
                    media: viewModel.spotlightMedia
                )) {
                    spotlightContent(artist: artist)
                }
            } else {
                // Loading state
                spotlightContent(artist: nil)
                    .redacted(reason: .placeholder)
                    .disabled(true)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.3).delay(1)) {
                slideInOffset = 0
            }
            Task {
                await viewModel.loadCurrentSpotlight()
            }
        }
    }
    
    @ViewBuilder
    private func spotlightContent(artist: SpotlightArtist?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header outside frame
            Text("Artist Spotlight")
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            ZStack {
                // Background Image
                if let artist = artist, let heroUrl = artist.hero_image_url {
                    CachedImageView(
                        urlString: heroUrl,
                        filename: URL(string: heroUrl)?.lastPathComponent ?? ""
                    )
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(backgroundScale)
                    .blur(radius: 1.5)
                    .clipped()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                            backgroundScale = 1.2
                        }
                    }
                }
                // Dark overlay
                Color.black.opacity(0.5)
                
                // Content overlay
                VStack(alignment: .center, spacing: 16) {
                    if let artist = artist {
                        Spacer(minLength: 0)
                        
                        VStack(spacing: 16) {
                            // Media Gallery
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.spotlightMedia.filter { $0.media_type != "audio" }) { media in
                                        MediaThumbnail(media: media)
                                    }
                                }
                            }
                            
                            // Extra Link if available
                            // if let link = artist.extra_link {
                            //     Link("Learn More", destination: URL(string: link)!)
                            //         .font(.system(size: 16))
                            //         .foregroundColor(.white)
                            //         .padding(8)
                            //         .background(Color.lcvaBlue.opacity(0.6))
                            //         .cornerRadius(8)
                            // }
                        }
                        .padding(.top, 420)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: 360, maxHeight: 440)
                .padding(.horizontal, 24)
                .offset(x: slideInOffset)
                
                // Artist Info overlay at top left
                if let artist = artist {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            // Artist Photo
                            if let photoUrl = artist.artist_photo_url {
                                CachedImageView(
                                    urlString: photoUrl,
                                    filename: URL(string: photoUrl)?.lastPathComponent ?? ""
                                )
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                Text(artist.artist_name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if let title = artist.art_title {
                                    Text(title)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        
                        if let bio = artist.bio {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Audio player
                        if let audioUrlString = artist.audio_url,
                           let audioUrl = URL(string: audioUrlString) {
                            AudioPlayerView(
                                audioUrl: audioUrl,
                                title: "Artist Audio"
                            )
                            .frame(maxWidth: 250, alignment: .leading)
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: 300, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .position(x: 170, y: 85)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .ignoresSafeArea()
        }
    }
}

// Media thumbnail component
struct MediaThumbnail: View {
    let media: SpotlightMedia
    
    var body: some View {
        Group {
            if media.media_type == "video" {
                VideoPreviewView(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 2)
            } else {
                CachedImageView(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 2)
            }
        }
    }
} 
