import SwiftUI

struct CollectionsView: View {
    @Binding var selectedArtPiece: ArtPiece?
    @State private var selectedFilter: CollectionFilter = .museum
    @State private var isGridView = false  // Add this to track view mode
    
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
                    
                    // Updated Recent header with functional grid toggle
                    HStack {
                        Text("Recents")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isGridView.toggle()
                            }
                        }) {
                            Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    // Updated collection items with grid/list toggle
                    ScrollView {
                        if isGridView {
                            LazyVStack(spacing: 12) {
                                let chunks = filteredArtPieces.chunked(into: 3)
                                ForEach(0..<chunks.count, id: \.self) { index in
                                    GridRow(items: chunks[index]) { artPiece in
                                        selectedArtPiece = artPiece
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // List Layout
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

// Add this new view for grid items
struct ArtPieceGridItem: View {
    let artPiece: ArtPiece
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Image container with fixed width
            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
            
            // Text container with same width as image
            VStack(alignment: .leading, spacing: 2) {
                Text(artPiece.title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Museum Collection")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 100)  // Match image width
        }
        .frame(maxWidth: .infinity, alignment: .center)  // Center in available space
        .onTapGesture(perform: onTap)
    }
}

// Add these at the top of the file
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct GridRow: View {
    let items: [ArtPiece]
    let onTap: (ArtPiece) -> Void
    @State private var rowHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { artPiece in
                ArtPieceGridItem(artPiece: artPiece, onTap: { onTap(artPiece) })
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: HeightPreferenceKey.self,
                            value: geo.size.height
                        )
                    })
                    .frame(height: rowHeight)
                    .frame(maxWidth: .infinity)
            }
            
            if items.count < 3 {
                ForEach(0..<(3 - items.count), id: \.self) { _ in
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            rowHeight = height
        }
    }
}

// Add this extension to help chunk the array
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
} 