import SwiftUI

struct CollectionsView: View {
    @Binding var selectedArtPiece: ArtPiece?
    @State private var selectedFilter: CollectionFilter = .museum
    
    enum CollectionFilter {
        case museum, personal, favorites, artists
    }
    
    var filteredArtPieces: [ArtPiece] {
        switch selectedFilter {
        case .museum:
            return featuredArtPieces  // This is our museum collection from ArtPiece.swift
        case .personal:
            return []  // TODO: Add personal collection
        case .favorites:
            return []  // TODO: Add favorites
        case .artists:
            return []  // TODO: Add artist pieces
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Content
                VStack {
                    // Header with title and buttons
                    HStack {
                        // User avatar/profile pic
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 35, height: 35)
                        
                        Text("Collections")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Search and Add buttons
                        Button(action: { /* Search action */ }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        
                        Button(action: { /* Add to collection action */ }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Updated filter buttons with selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(title: "Museum Collection", 
                                       isSelected: selectedFilter == .museum) {
                                selectedFilter = .museum
                            }
                            FilterButton(title: "Your Collection", 
                                       isSelected: selectedFilter == .personal) {
                                selectedFilter = .personal
                            }
                            FilterButton(title: "Favorites", 
                                       isSelected: selectedFilter == .favorites) {
                                selectedFilter = .favorites
                            }
                            FilterButton(title: "Artists", 
                                       isSelected: selectedFilter == .artists) {
                                selectedFilter = .artists
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent header with sort/view options
                    HStack {
                        Text("Recents")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Grid view toggle
                        Button(action: { /* Toggle view */ }) {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    // Updated collection items to use filtered pieces
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredArtPieces) { artPiece in
                                ArtPieceRow(artPiece: artPiece) {
                                    selectedArtPiece = artPiece
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Helper view for filter buttons
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

// Helper view for art piece rows
struct ArtPieceRow: View {
    let artPiece: ArtPiece
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading) {
                Text(artPiece.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Museum Collection")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .onTapGesture(perform: onTap)
    }
} 