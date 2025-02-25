import SwiftUI
import MapKit

struct ArtDetailView: View {
    let artPiece: ArtPiece
    @ObservedObject var userManager: UserManager
    @ObservedObject var userCollections: UserCollections
    @State private var isMapExpanded = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero Image
                    AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 300)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 300)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Actions
                        HStack {
                            Text(artPiece.title)
                                .font(.title)
                                .bold()
                            
                            Spacer()
                            
                            // Collection and Favorite buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    if userCollections.isInCollection(artPiece) {
                                        userCollections.removeFromCollection(artPiece)
                                    } else {
                                        userCollections.addToCollection(artPiece)
                                    }
                                }) {
                                    Image(systemName: userCollections.isInCollection(artPiece) ? "minus.circle.fill" : "plus.circle.fill")
                                        .font(.title2)
                                }
                                
                                Button(action: {
                                    userCollections.toggleFavorite(artPiece)
                                }) {
                                    Image(systemName: userCollections.isFavorite(artPiece) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(userCollections.isFavorite(artPiece) ? .red : .primary)
                                }
                            }
                        }
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(title: "Material", content: artPiece.material)
                            DetailRow(title: "Era", content: artPiece.era)
                            DetailRow(title: "Origin", content: artPiece.origin)
                        }
                        .padding(.vertical)
                        
                        // Description
                        Text("About")
                            .font(.headline)
                        Text(artPiece.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Lore Section
                        if !artPiece.lore.isEmpty {
                            Text("Historical Context")
                                .font(.headline)
                                .padding(.top)
                            Text(artPiece.lore)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Replace the map button with a DisclosureGroup
                        DisclosureGroup(
                            isExpanded: $isMapExpanded,
                            content: {
                                MapViewRepresentable(artPiece: artPiece)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                                    .padding(.top, 8)
                            },
                            label: {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Location")
                                    Spacer()
                                    Text("View on Map")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                            }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Update chat section styling
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Discussion")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.leading)
                            
                            ChatView(artPieceID: artPiece.id, userManager: userManager)
                                .frame(height: 300)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 3)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// Helper view for detail rows
struct DetailRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(content)
                .font(.body)
        }
    }
} 