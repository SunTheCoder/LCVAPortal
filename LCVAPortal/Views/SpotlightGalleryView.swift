import SwiftUI

struct SpotlightGalleryView: View {
    let artist: SpotlightArtist
    private let media: [SpotlightMedia]
    // Computed property to ensure consistent sorting
    private var sortedMedia: [SpotlightMedia] {
        media.sorted { $0.media_order > $1.media_order }
    }
    @State private var selectedMedia: SpotlightMedia?
    @Environment(\.dismiss) var dismiss
    
    init(artist: SpotlightArtist, media: [SpotlightMedia]) {
        self.artist = artist
        self.media = media
        print("🎨 Gallery View Created")
        print("📱 Media array order:")
        media.sorted { $0.media_order > $1.media_order }.enumerated().forEach { index, m in
            print("  \(index). \(m.id) - \(m.media_url.split(separator: "/").last ?? "")")
        }
    }
    
    // Add debug print to track selection
    private func selectMedia(_ item: SpotlightMedia) {
        print("📱 Selecting media: \(item.id)")
        print("🔗 Selected URL: \(item.media_url)")
        print("📱 Selected type: \(item.media_type)")
        print("🔢 Media order: \(item.media_order)")
        print("📍 Index in sorted array: \(sortedMedia.firstIndex(where: { $0.id == item.id }) ?? -1)")
        selectedMedia = item
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section
                ZStack(alignment: .bottom) {
                    // Background Image
                    if let heroUrl = artist.hero_image_url {
                        CachedImageView(
                            urlString: heroUrl,
                            filename: URL(string: heroUrl)?.lastPathComponent ?? ""
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(artist.artist_name)
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                            
                            if let title = artist.art_title {
                                Text(title)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                            }
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
                    
                    LazyVStack(spacing: 32) {
                        Spacer(minLength: 24)  // Top padding
                        // Show all media in original order
                        ForEach(sortedMedia) { item in
                            MediaGridItem(media: item)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    selectMedia(item)
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
        .fullScreenCover(item: $selectedMedia) { media in
            MediaDetailView(media: media) {
                selectedMedia = nil
            }
        }
    }
}

struct MediaDetailView: View {
    let media: SpotlightMedia
    let onDismiss: () -> Void
    @State private var isLandscape = false
    @State private var isAnimating = false
    
    init(media: SpotlightMedia, onDismiss: @escaping () -> Void) {
        self.media = media
        self.onDismiss = onDismiss
        print("🖼️ Opening detail view for: \(media.id)")
        print("🔗 Media URL: \(media.media_url)")
        print("📱 Media type: \(media.media_type)")
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if media.media_type == "video" {
                GalleryVideoPlayer(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .aspectRatio(contentMode: .fit)
            } else {
                GeometryReader { geo in
                    CachedImageView(
                        urlString: media.media_url,
                        filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: isLandscape ? geo.size.height : geo.size.width,
                        height: isLandscape ? geo.size.width : geo.size.height
                    )
                    .position(
                        x: geo.size.width / 2,
                        y: geo.size.height / 2
                    )
                    .rotationEffect(.degrees(isLandscape ? 90 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isLandscape)
                }
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
                    .disabled(isAnimating)
                    
                    Spacer()
                    
                    // Rotate button for images only
                    if media.media_type == "image" {
                        Button(action: {
                            isAnimating = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isLandscape.toggle()
                            } completion: {
                                isAnimating = false
                            }
                        }) {
                            Image(systemName: "rotate.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                        .disabled(isAnimating)
                    }
                }
                Spacer()
            }
        }
        .statusBar(hidden: isLandscape)
        .interactiveDismissDisabled(isAnimating)
    }
}

struct MediaGridItem: View {
    let media: SpotlightMedia
    @State private var isDescriptionExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if media.media_type == "video" {
                    VideoPreviewView(
                        urlString: media.media_url,
                        filename: URL(string: media.media_url)?.lastPathComponent ?? ""
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
                    .contentShape(Rectangle())
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
            .contentShape(Rectangle())
            
            // Media details
            VStack(alignment: .leading, spacing: 4) {
                if let title = media.title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                if let description = media.description {
                    DisclosureGroup(
                        isExpanded: $isDescriptionExpanded,
                        content: {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.vertical, 8)
                        },
                        label: {
                            HStack {
                                Text("Description")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                                    .rotationEffect(.degrees(isDescriptionExpanded ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: isDescriptionExpanded)
                            }
                        }
                    )
                    .tint(.clear)
                    .accentColor(.white)
                }
                
                if let medium = media.medium {
                    Text(medium)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 15)
        }
        .padding(.horizontal, 15)
        .animation(.easeInOut(duration: 0.2), value: isDescriptionExpanded)
    }
} 
