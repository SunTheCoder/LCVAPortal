import SwiftUI

struct CollectionsView: View {
    @Binding var selectedArtPiece: ArtPiece?
    @State private var selectedFilter: CollectionFilter = .museum
    @State private var isGridView = false  // Add this to track view mode
    @StateObject private var userCollections = UserCollections()
    @ObservedObject var userManager: UserManager
    @State private var showingAllFilters = true  // New state to track filter view mode
    @State private var activeOverlayId: Int? = nil  // Track active overlay by art piece ID
    @Namespace private var filterAnimation  // Add this for matched geometry effect
    @State private var selectedSubFilter: SubFilter? = nil
    @Namespace private var subFilterAnimation
    
    // Move enum outside the struct
    private var filterTitle: String {
        switch selectedFilter {
        case .museum: return "Museum Collection"
        case .personal: return "Your Collection"
        case .favorites: return "Favorites"
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
        }
    }
    
    // Add computed property for displayed art
    var displayedArtPieces: [ArtPiece] {
        switch selectedFilter {
        case .museum:
            return featuredArtPieces.prefix(5).map { $0 }  // Just show first 5 for now
        case .personal:
            return userCollections.personalCollection.prefix(5).map { $0 }
        case .favorites:
            return userCollections.favorites.prefix(5).map { $0 }
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
                            NavigationLink(destination: SearchView(
                                artPieces: featuredArtPieces,
                                userCollections: userCollections,
                                userManager: userManager
                            )) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Button(action: { /* Add to collection action */ }) {
                        //     Image(systemName: "plus")
                        //         .foregroundColor(.white)
                        // }
                    }
                    .padding(.horizontal)
                    
                    // Updated filter buttons with animation
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if !showingAllFilters {
                                // Close button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showingAllFilters = true
                                        selectedFilter = .museum
                                        selectedSubFilter = nil  // Reset sub-filter
                                    }
                                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                                    impactLight.impactOccurred()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.leading)
                                .transition(.opacity.combined(with: .scale))
                                
                                // Selected filter
                                FilterButton(
                                    title: filterTitle,
                                    isSelected: true
                                ) {
                                    // Already selected, do nothing
                                }
                                .matchedGeometryEffect(id: selectedFilter, in: filterAnimation)
                                
                                // Sub-filters appear after selected filter
                                ForEach([SubFilter.artist, SubFilter.medium], id: \.self) { filter in
                                    FilterButton(
                                        title: filter.title,
                                        isSelected: selectedSubFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if selectedSubFilter == filter {
                                                selectedSubFilter = nil
                                            } else {
                                                selectedSubFilter = filter
                                            }
                                        }
                                        let impactLight = UIImpactFeedbackGenerator(style: .light)
                                        impactLight.impactOccurred()
                                    }
                                    .matchedGeometryEffect(id: filter, in: subFilterAnimation)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .trailing).combined(with: .opacity)
                                    ))
                                }
                            } else {
                                // Main filter options
                                ForEach([
                                    ("Museum Collection", CollectionFilter.museum),
                                    ("Your Collection", CollectionFilter.personal),
                                    ("Favorites", CollectionFilter.favorites)
                                ], id: \.0) { title, filter in
                                    FilterButton(
                                        title: title,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedFilter = filter
                                            showingAllFilters = false
                                            selectedSubFilter = nil  // Reset sub-filter when main filter changes
                                        }
                                        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
                                        impactMedium.impactOccurred()
                                    }
                                    .matchedGeometryEffect(id: filter, in: filterAnimation)
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingAllFilters)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSubFilter)
                    
                    // On Display Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("On Display")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(displayedArtPieces) { artPiece in
                                    NavigationLink(destination: ArtDetailView(
                                        artPiece: artPiece,
                                        userManager: userManager,
                                        userCollections: userCollections
                                    )) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 160, height: 160)
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                            } placeholder: {
                                                ProgressView()
                                                    .frame(width: 160, height: 160)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(artPiece.title)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(artPiece.material)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .lineLimit(1)
                                            }
                                            .frame(height: 50)
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: 160)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    
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
                                        userManager: userManager,
                                        activeOverlayId: $activeOverlayId
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .onChange(of: selectedFilter) { _ in
                                // Clear active overlay when filter changes
                                activeOverlayId = nil
                            }
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
    @Binding var activeOverlayId: Int?  // Binding to shared state
    @State private var scale: CGFloat = 1.0
    @State private var shouldNavigate = false  // Add this back
    
    var isLongPressed: Bool {
        activeOverlayId == artPiece.id
    }
    
    var body: some View {
        Group {
            if isLongPressed {
                contentView
            } else {
                NavigationLink(
                    destination: ArtDetailView(
                        artPiece: artPiece,
                        userManager: userManager,
                        userCollections: userCollections
                    ),
                    isActive: $shouldNavigate  // Bind to navigation state
                ) {
                    contentView
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                // Image container
                AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
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
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }) {
                            Image(systemName: userCollections.isInCollection(artPiece) ? "minus.circle.fill" : "plus.circle.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Button(action: {
                            userCollections.toggleFavorite(artPiece)
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
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    if isLongPressed {
                        activeOverlayId = nil
                    } else {
                        activeOverlayId = artPiece.id
                    }
                    scale = isLongPressed ? 1.1 : 1.0
                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                    impactHeavy.impactOccurred()
                }
                
                if !isLongPressed {
                    scale = 1.0
                } else {
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
                        activeOverlayId = nil
                        let impactLight = UIImpactFeedbackGenerator(style: .light)
                        impactLight.impactOccurred()
                    }
                } else {
                    shouldNavigate = true  // Trigger navigation when no overlay
                }
            }
            
            // Text container
            VStack(alignment: .leading, spacing: 2) {
                Text(artPiece.title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("Museum Collection")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 100)
        }
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
    @Binding var activeOverlayId: Int?  // Binding to shared state
    @State private var rowHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(items) { artPiece in
                ArtPieceGridItem(
                    artPiece: artPiece,
                    onTap: { onTap(artPiece) },
                    userCollections: userCollections,
                    userManager: userManager,
                    activeOverlayId: $activeOverlayId
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
    case museum, personal, favorites  // Remove artists case
}

enum SubFilter {
    case artist, medium
    
    var title: String {
        switch self {
        case .artist: return "Artist"
        case .medium: return "Medium"
        }
    }
} 
