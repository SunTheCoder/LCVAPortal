import SwiftUI

struct ArtistSpotlightView: View {
    @StateObject private var viewModel = SpotlightViewModel()
    @State private var selectedMedia: SpotlightMedia?
    @State private var isMediaEnlarged = false
    @State private var slideInOffset: CGFloat = -UIScreen.main.bounds.width
    @State private var backgroundScale: CGFloat = 1.0
    
    var body: some View {
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
                if let firstImage = viewModel.spotlightMedia.first(where: { $0.media_type == "image" }) {
                    CachedImageView(
                        urlString: firstImage.media_url,
                        filename: URL(string: firstImage.media_url)?.lastPathComponent ?? ""
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
                    if let artist = viewModel.currentArtist {
                        Spacer(minLength: 0)
                        
                        VStack(spacing: 16) {
                            // Media Gallery
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.spotlightMedia.sorted(by: { $0.media_order < $1.media_order })) { media in
                                        MediaThumbnail(media: media)
                                            .onTapGesture {
                                                selectedMedia = media
                                                isMediaEnlarged = true
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Extra Link if available
                            if let link = artist.extra_link {
                                Link("Learn More", destination: URL(string: link)!)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.lcvaBlue.opacity(0.6))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 390)
                        .padding(.bottom, 24)
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: 360, maxHeight: 440)
                .padding(.horizontal, 24)
                .offset(x: slideInOffset)
                
                // Artist Info overlay at top left
                if let artist = viewModel.currentArtist {
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
                    }
                    .frame(maxWidth: 300, alignment: .leading)
                    .padding(.horizontal, 24)
                    .position(x: 170, y: 85)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.3).delay(1)) {
                slideInOffset = 0
            }
            Task {
                await viewModel.loadCurrentSpotlight()
            }
        }
        .fullScreenCover(isPresented: $isMediaEnlarged) {
            if let media = selectedMedia {
                EnlargedMediaView(media: media, isPresented: $isMediaEnlarged)
            }
        }
    }
}

// Media thumbnail component
struct MediaThumbnail: View {
    let media: SpotlightMedia
    
    var body: some View {
        Group {
            if media.media_type == "video" {
                CachedVideoPlayer(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
                .overlay(
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                )
                .contentShape(Rectangle())
            } else {
                CachedImageView(
                    urlString: media.media_url,
                    filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                )
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
            }
        }
    }
}

// Enlarged media view
struct EnlargedMediaView: View {
    let media: SpotlightMedia
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    if media.media_type == "video" {
                        CachedVideoPlayer(
                            urlString: media.media_url,
                            filename: URL(string: media.media_url)?.lastPathComponent ?? ""
//                            autoPlay: true
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .edgesIgnoringSafeArea(.all)
                    } else {
                        CachedImageView(
                            urlString: media.media_url,
                            filename: URL(string: media.media_url)?.lastPathComponent ?? ""
                        )
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale * gestureScale)
                        .gesture(
                            MagnificationGesture()
                                .updating($gestureScale) { currentState, gestureState, _ in
                                    gestureState = currentState
                                }
                                .onEnded { value in
                                    scale *= value
                                    scale = min(max(scale, 1), 4)
                                }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        scale = 1.0
                        isPresented = false
                    }
                }
            }
        }
    }
} 
