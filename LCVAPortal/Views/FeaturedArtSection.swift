import SwiftUI

struct FeaturedArtSection: View {
    @State private var currentIndex = 0
    let featuredArtPieces: [ArtPiece]
    let userManager: UserManager
    let userCollections: UserCollections
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Art")
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.white)
            
            if !featuredArtPieces.isEmpty {
                let artPiece = featuredArtPieces[currentIndex]
                
                HStack(spacing: 16) {
                    // Left chevron
                    Button(action: {
                        withAnimation {
                            currentIndex = max(currentIndex - 1, 0)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .opacity(currentIndex == 0 ? 0.3 : 1)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(currentIndex == 0)
                    
                    // Main content
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(destination: ArtDetailView(
                            artPiece: artPiece,
                            userManager: userManager,
                            userCollections: userCollections
                        )) {
                            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 280, height: 200)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 280, height: 200)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(artPiece.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text(artPiece.artist)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Right chevron
                    Button(action: {
                        withAnimation {
                            currentIndex = min(currentIndex + 1, featuredArtPieces.count - 1)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .opacity(currentIndex == featuredArtPieces.count - 1 ? 0.3 : 1)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(currentIndex == featuredArtPieces.count - 1)
                }
            }
        }
        .padding(.horizontal)
    }
} 
