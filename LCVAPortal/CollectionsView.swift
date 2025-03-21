import SwiftUI
import FirebaseFirestore
import Foundation

struct CollectionsView: View {
    @Binding var selectedArtPiece: ArtPiece?
    @State private var selectedFilter: CollectionFilter = .museum
    @State private var isGridView = false  // Add this to track view mode
    @StateObject private var userCollections = UserCollections()
    @ObservedObject var userManager: UserManager
    @State private var showingAllFilters = true  // New state to track filter view mode
    @State private var activeOverlayId: UUID? = nil  // Change from Int? to UUID?
    @Namespace private var filterAnimation  // Add this for matched geometry effect
    @State private var selectedSubFilter: SubFilter? = nil
    @Namespace private var subFilterAnimation
    @State private var userAvatar: String? = nil
    @State private var showingJournal = false
    
    // Add Supabase data states
    @EnvironmentObject var artifactManager: ArtifactManager
    
    private let supabase = SupabaseClient.shared  // Add this line
    private let artifactService = ArtifactService.shared
    
    // Move enum outside the struct
    private var filterTitle: String {
        switch selectedFilter {
        case .museum: return "Museum Collection"
        case .personal: return "Your Collection"
        }
    }
    
    // Convert Supabase Artifact to ArtPiece for now (we'll phase this out later)
    private func convertToArtPiece(_ artifact: Artifact) -> ArtPiece {
        // print("🔄 Converting artifact:", artifact)
        let artPiece = ArtPiece(
            id: artifact.id,
            title: artifact.title,
            artist: artifact.artist,
            description: artifact.description ?? "",
            imageUrl: artifact.image_url ?? "",
            latitude: 0.0,  // Default values for now
            longitude: 0.0,
            material: artifact.collection ?? "",
            era: "",        // Default empty string
            origin: "",     // Default empty string
            lore: "",      // Default empty string
            translations: nil,
            audioTour: nil,
            brailleLabel: nil,
            adaAccessibility: nil
           
        )
        // print("✨ Converted to ArtPiece:", artPiece)
        return artPiece
    }
    
    // Update filteredArtPieces to handle sub-filters
    var filteredArtPieces: [ArtPiece] {
        switch selectedFilter {
        case .museum:
            let artifacts = artifactManager.artifacts
            
            // Apply sub-filter if selected
            if let subFilter = selectedSubFilter {
                return artifacts
                    .filter { artifact in
                        artifact.collection?.lowercased() == subFilter.collectionName.lowercased()
                    }
                    .map(convertToArtPiece)
            }
            
            return artifacts.map(convertToArtPiece)
            
        case .personal:
            let personalArtPieces = userCollections.personalCollection
            
            // Apply sub-filter if selected
            if let subFilter = selectedSubFilter {
                print("🔍 Filtering personal collection with: \(subFilter.title)")
                print("📚 Personal collection count: \(personalArtPieces.count)")
                
                let filtered = personalArtPieces.filter { artPiece in
                    print("🎨 Comparing: '\(artPiece.material)' with '\(subFilter.collectionName)'")
                    return artPiece.material.lowercased() == subFilter.collectionName.lowercased()
                }
                
                print("✅ Filtered count: \(filtered.count)")
                return filtered
            }
            
            return userCollections.personalCollection
        }
    }
    
    // Update displayedArtPieces to use Supabase data
    var displayedArtPieces: [ArtPiece] {
        switch selectedFilter {
        case .museum:
            return artifactManager.artifacts
                .filter { $0.on_display }
                .map(convertToArtPiece)
        case .personal:
            return userCollections.personalCollection.prefix(5).map { $0 }
        }
    }
    
    private func fetchUserAvatar() {
        guard let uid = userManager.currentUser?.uid else { return }
        
        Task {
            do {
                let user = try await supabase.fetchUser(id: uid)
                await MainActor.run {
                    self.userAvatar = user.avatar_url
                }
            } catch {
                print("❌ Error fetching user avatar:", error)
            }
        }
    }
    
    // Add helper method to handle sub-filter selection
    private func handleSubFilterSelection(_ subFilter: SubFilter) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if selectedSubFilter == subFilter {
                // Deselect if tapping the same filter
                selectedSubFilter = nil
            } else {
                selectedSubFilter = subFilter
            }
            showingAllFilters = false
        }
        
        // Haptic feedback
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactMedium.impactOccurred()
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Content
                VStack {
                    // Header with title and buttons
                    HStack {
                        // User avatar/profile pic
                        Button {
                            showingJournal = true
                        } label: {
                            if let avatarUrl = userAvatar {
                                AsyncImage(url: URL(string: avatarUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 35, height: 35)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 35, height: 35)
                                }
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 35, height: 35)
                            }
                        }
                        
                        Text("Collections")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Search and Add buttons
                        Button(action: { /* Search action */ }) {
                            NavigationLink(destination: SearchView(
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
                                ForEach([
                                    SubFilter.african, .american, .chinese,
                                    .childrenLit, .civilRights, .contemporary,
                                    .decorative, .folkArt, .virginia
                                ], id: \.self) { filter in
                                    FilterButton(
                                        title: filter.title,
                                        isSelected: selectedSubFilter == filter
                                    ) {
                                        handleSubFilterSelection(filter)
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
                                ], id: \.0) { title, filter in
                                    FilterButton(
                                        title: title,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedFilter = filter
                                            showingAllFilters = false
                                            selectedSubFilter = nil  // Reset sub-filter
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("On Display")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if artifactManager.isLoading {
                                    // Loading placeholders
                                    ForEach(0..<3) { _ in
                                        VStack(alignment: .leading, spacing: 4) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.white.opacity(0.2))
                                                .frame(width: 160, height: 160)
                                                .overlay(ProgressView())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(height: 16)
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(height: 12)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: 160)
                                    }
                                } else if let error = artifactManager.error {
                                    // Show error with existing styling
                                    VStack(alignment: .center) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                        Text(error)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        Button("Retry") {
                                            Task {
                                                await artifactManager.preloadArtifacts()
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding(.top)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                } else {
                                    // Existing ForEach with displayedArtPieces
                                    ForEach(displayedArtPieces) { artPiece in
                                        NavigationLink(destination: ArtDetailView(
                                            artPiece: artPiece,
                                            userManager: userManager,
                                            userCollections: userCollections
                                        )) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                CachedCollectionImageView(
                                                    urlString: artPiece.imageUrl,
                                                    filename: "\(artPiece.id)-collection.jpg"
                                                )
                                                    .frame(width: 160, height: 160)
                                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                                
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
                        if artifactManager.isLoading {
                            if isGridView {
                                // Grid loading state
                                LazyVStack(spacing: 12) {
                                    ForEach(0..<3) { _ in
                                        HStack(spacing: 12) {
                                            ForEach(0..<3) { _ in
                                                VStack(alignment: .leading, spacing: 4) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.white.opacity(0.2))
                                                        .frame(width: 100, height: 100)
                                                        .overlay(ProgressView())
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .fill(Color.white.opacity(0.2))
                                                            .frame(height: 12)
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .fill(Color.white.opacity(0.2))
                                                            .frame(height: 8)
                                                    }
                                                    .frame(width: 100)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            } else {
                                // List loading state
                                LazyVStack(spacing: 16) {
                                    ForEach(0..<5) { _ in
                                        HStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.white.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                                .overlay(ProgressView())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(height: 16)
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(height: 12)
                                            }
                                            .padding(.horizontal)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        } else if let error = artifactManager.error {
                            // Error state
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text(error)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Button("Retry") {
                                    Task {
                                        await artifactManager.preloadArtifacts()
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .padding()
                        } else {
                            // Existing grid/list view code
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
        .onAppear {
            fetchUserAvatar()
            Task {
                await artifactManager.preloadArtifacts()
            }
            // Add this to load collections when view appears
            if let userId = userManager.currentUser?.uid {
                Task {
                    await userCollections.loadUserCollections(userId: userId)
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
                CachedArtifactsListView(
                    urlString: artPiece.imageUrl,
                    filename: "\(artPiece.id)-list.jpg"
                )
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
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
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        } else {
                            userCollections.addToCollection(artPiece)
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        }
                    }) {
                        Image(systemName: userCollections.isInCollection(artPiece) ? "heart.fill" : "heart")
                            .foregroundColor(userCollections.isInCollection(artPiece) ? .red : .white)
                            .font(.title2)
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
    @Binding var activeOverlayId: UUID?  // Change from Int? to UUID?
    @State private var scale: CGFloat = 1.0
    @State private var shouldNavigate = false
    
    var isLongPressed: Bool {
        activeOverlayId == artPiece.id  // This comparison now works with UUIDs
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
                CachedArtifactsGridView(
                    urlString: artPiece.imageUrl,
                    filename: "\(artPiece.id)-grid.jpg"
                )
                    .frame(width: 100, height: 100)
                
                // Long press overlay
                if isLongPressed {
                    Color.black.opacity(0.5)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            if userCollections.isInCollection(artPiece) {
                                userCollections.removeFromCollection(artPiece)
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            } else {
                                userCollections.addToCollection(artPiece)
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                            }
                        }) {
                            Image(systemName: userCollections.isInCollection(artPiece) ? "heart.fill" : "heart")
                                .foregroundColor(userCollections.isInCollection(artPiece) ? .red : .white)
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
    @Binding var activeOverlayId: UUID?  // Binding to shared state
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
    case museum, personal
}

enum SubFilter {
    case african, american, chinese
    case childrenLit, civilRights, contemporary
    case decorative, folkArt, virginia
    
    var title: String {
        switch self {
        case .african: return "African Art"
        case .american: return "American Art"
        case .chinese: return "Chinese Art"
        case .childrenLit: return "Children's Lit"
        case .civilRights: return "Civil & Human Rights"
        case .contemporary: return "Contemporary Art"
        case .decorative: return "Decorative Art"
        case .folkArt: return "Folk Art"
        case .virginia: return "Virginia Artists"
        }
    }
    
    var collectionName: String {
        switch self {
        case .african: return "African Art"
        case .american: return "American Art"
        case .chinese: return "Chinese Art"
        case .childrenLit: return "Children's Lit"
        case .civilRights: return "Civil & Human Rights"
        case .contemporary: return "Contemporary Art"
        case .decorative: return "Decorative Art"
        case .folkArt: return "Folk Art"
        case .virginia: return "Virginia Artists"
        }
    }
}

enum Tab {
    case personal
} 
