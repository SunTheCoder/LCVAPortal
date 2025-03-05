import SwiftUI

struct SpotlightGalleryView: View {
    let artist: SpotlightArtist
    let media: [SpotlightMedia]
    @State private var selectedMedia: SpotlightMedia?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                ZStack(alignment: .bottom) {
                    // Background Image
                    if let firstImage = media.first(where: { $0.media_type == "image" }) {
                        CachedImageView(
                            urlString: firstImage.media_url,
                            filename: URL(string: firstImage.media_url)?.lastPathComponent ?? ""
                        )
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 360)
                        .blur(radius: 2)
                        .overlay(
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    
                    // Artist Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(artist.artist_name)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        if let title = artist.art_title {
                            Text(title)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        HStack {
                            if let photoUrl = artist.artist_photo_url {
                                CachedImageView(
                                    urlString: photoUrl,
                                    filename: URL(string: photoUrl)?.lastPathComponent ?? ""
                                )
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Action Buttons
                            HStack(spacing: 20) {
                                Button(action: { /* Share action */ }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                                if let link = artist.extra_link {
                                    Link(destination: URL(string: link)!) {
                                        Text("Learn More")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
                
                // Bio Section
                if let bio = artist.bio {
                    Text(bio)
                        .foregroundColor(.white)
                        .padding(24)
                }
                
                // Media Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gallery")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    LazyVStack(spacing: 16) {
                        Spacer(minLength: 24)  // Top padding
                        ForEach(media.sorted(by: { $0.media_order > $1.media_order })) { item in
                            MediaGridItem(media: item)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    selectedMedia = item
                                }
                        }
                        Spacer(minLength: 24)  // Bottom padding
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .sheet(item: $selectedMedia) { media in
            MediaDetailView(media: media) {
                selectedMedia = nil
            }
        }
    }
}

struct MediaDetailView: View {
    let media: SpotlightMedia
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if media.media_type == "video" {
                CachedVideoPlayer(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? "",
                    autoPlay: true
                )
                .aspectRatio(contentMode: .fit)
            } else {
                CachedImageView(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .aspectRatio(contentMode: .fit)
            }
            
            // Close button
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct MediaGridItem: View {
    let media: SpotlightMedia
    
    var body: some View {
        Group {
            if media.media_type == "video" {
                CachedVideoPlayer(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? "",
                    autoPlay: true
                )
                .aspectRatio(16/9, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                CachedImageView(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipped()
                .overlay(
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                        .padding(12),
                    alignment: .bottomTrailing
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
} 