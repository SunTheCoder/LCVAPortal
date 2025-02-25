import SwiftUI

struct CollectionsView: View {
    @Binding var selectedArtPiece: ArtPiece?
    @State private var selectedFilter: CollectionFilter = .museum
    @State private var isGridView = false  // Add this to track view mode
    @StateObject private var userCollections = UserCollections()
    @ObservedObject var userManager: UserManager
    @State private var showingAllFilters = true  // New state to track filter view mode
    
    // Move enum outside the struct
    private var filterTitle: String {
        switch selectedFilter {
        case .museum: return "Museum Collection"
        case .personal: return "Your Collection"
        case .favorites: return "Favorites"
        case .artists: return "Artists"
        }
    }
    
    var filteredArtPieces: [ArtPiece] {
        switch selectedFilter {
        case .museum:
            return featuredArtPieces  // This is our museum collection from ArtPiece.swift
        case .personal:
            return userCollections.personalCollection
        case .favorites:
            return userCollections.favorites
        case .artists:
            return []  // TODO: Add artist pieces
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
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
                    
                    // Updated filter buttons with animation
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if !showingAllFilters {
                                // Close button with fade animation
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showingAllFilters = true
                                        selectedFilter = .museum  // Reset to default museum collection
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.leading)
                                .transition(.opacity.combined(with: .scale))
                                
                                // Selected filter with slide animation
                                FilterButton(
                                    title: filterTitle,
                                    isSelected: true
                                ) {
                                    // Already selected, do nothing
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            } else {
                                // All filter options with fade animations
                                ForEach([
                                    ("Museum Collection", CollectionFilter.museum),
                                    ("Your Collection", CollectionFilter.personal),
                                    ("Favorites", CollectionFilter.favorites),
                                    ("Artists", CollectionFilter.artists)
                                ], id: \.0) { title, filter in
                                    FilterButton(
                                        title: title,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedFilter = filter
                                            showingAllFilters = false
                                        }
                                    }
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingAllFilters)
                    
                    // Updated Recent header with functional grid toggle
                    HStack {
                        Text("Artifacts")
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
                                    GridRow(
                                        items: chunks[index],
                                        onTap: { artPiece in selectedArtPiece = artPiece },
                                        userCollections: userCollections,
                                        userManager: userManager
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            // List Layout
                            LazyVStack(spacing: 16) {
                                ForEach(filteredArtPieces) { artPiece in
                                    ArtPieceRow(
                                        artPiece: artPiece,
                                        onTap: { selectedArtPiece = artPiece },
                                        userCollections: userCollections,
                                        userManager: userManager
                                    )
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
                .font(.caption)  // Smaller text
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(.white)
                .padding(.horizontal, 12)  // Reduced horizontal padding
                .padding(.vertical, 6)     // Reduced vertical padding
                .background(
                    Capsule()
                        .fill(isSelected ? 
                            Color.white.opacity(0.3) : 
                            Color.black.opacity(0.2)
                        )
                )
                .animation(.easeInOut, value: isSelected)
        }
    }
}

// Helper view for art piece rows
struct ArtPieceRow: View {
    let artPiece: ArtPiece
    let onTap: () -> Void
    @ObservedObject var userCollections: UserCollections
    let userManager: UserManager
    
    var body: some View {
        NavigationLink(destination: ArtDetailView(
            artPiece: artPiece,
            userManager: userManager,
            userCollections: userCollections
        )) {
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
                
                // Collection and favorite buttons
                HStack(spacing: 12) {
                    Button(action: {
                        if userCollections.isInCollection(artPiece) {
                            userCollections.removeFromCollection(artPiece)
                        } else {
                            userCollections.addToCollection(artPiece)
                        }
                    }) {
                        Image(systemName: userCollections.isInCollection(artPiece) ? "minus.circle.fill" : "plus.circle.fill")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        userCollections.toggleFavorite(artPiece)
                    }) {
                        Image(systemName: userCollections.isFavorite(artPiece) ? "heart.fill" : "heart")
                            .foregroundColor(userCollections.isFavorite(artPiece) ? .red : .white)
                    }
                }
                
                NavigationLink(destination: ChatView(artPieceID: artPiece.id, userManager: userManager)) {
                    Image(systemName: "bubble.left.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
        }
        .foregroundColor(.primary) // This keeps the row styling consistent
    }
}

// Add this new view for grid items
struct ArtPieceGridItem: View {
    let artPiece: ArtPiece
    let onTap: () -> Void
    @ObservedObject var userCollections: UserCollections
    let userManager: UserManager
    @State private var isLongPressed = false
    @State private var scale: CGFloat = 1.0  // For scale animation
    
    var body: some View {
        NavigationLink(destination: ArtDetailView(
            artPiece: artPiece,
            userManager: userManager,
            userCollections: userCollections
        )) {
            VStack(alignment: .leading, spacing: 4) {
                ZStack {
                    // Image container
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
                    
                    // Long press overlay
                    if isLongPressed {
                        Color.black.opacity(0.5)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                if userCollections.isInCollection(artPiece) {
                                    userCollections.removeFromCollection(artPiece)
                                } else {
                                    userCollections.addToCollection(artPiece)
                                }
                                
                                // Add haptic feedback for confirmation
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }) {
                                Image(systemName: userCollections.isInCollection(artPiece) ? "minus.circle.fill" : "plus.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            
                            Button(action: {
                                userCollections.toggleFavorite(artPiece)
                                
                                // Add haptic feedback for confirmation
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }) {
                                Image(systemName: userCollections.isFavorite(artPiece) ? "heart.fill" : "heart")
                                    .foregroundColor(userCollections.isFavorite(artPiece) ? .red : .white)
                                    .font(.title2)
                            }
                            
                            NavigationLink(destination: ChatView(artPieceID: artPiece.id, userManager: userManager)) {
                                Image(systemName: "bubble.left.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                    }
                }
                .scaleEffect(scale)  // Apply scale animation
                .onLongPressGesture(minimumDuration: 0.3) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        // Toggle the overlay
                        isLongPressed.toggle()
                        scale = isLongPressed ? 1.1 : 1.0
                        
                        // Haptic feedback
                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                        impactHeavy.impactOccurred()
                    }
                    
                    if !isLongPressed {
                        // Reset scale immediately if dismissing
                        scale = 1.0
                    } else {
                        // Reset scale after a brief delay if showing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                scale = 1.0
                            }
                        }
                    }
                }
                .onTapGesture {
                    if isLongPressed {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isLongPressed = false
                            // Light haptic feedback when dismissing
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                        }
                    } else {
                        onTap()
                    }
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
        }
        .buttonStyle(PlainButtonStyle()) // This preserves the grid item styling
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
    let userCollections: UserCollections
    let userManager: UserManager
    @State private var rowHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { artPiece in
                ArtPieceGridItem(
                    artPiece: artPiece,
                    onTap: { onTap(artPiece) },
                    userCollections: userCollections,
                    userManager: userManager
                )
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

// Define enum at file level
enum CollectionFilter {
    case museum, personal, favorites, artists
} 
