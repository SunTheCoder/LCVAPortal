import SwiftUI
import AVKit

extension Color {
    static let lcvaNavy = Color(red: 13/255, green: 27/255, blue: 62/255)  // Dark navy
    static let lcvaBlue = Color(red: 52/255, green: 144/255, blue: 220/255)  // Lighter blue
}

struct SplashView: View {
    @Binding var isPresented: Bool
    @State private var isAnimating = false
    @State private var opacity: CGFloat = 1
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(opacity)
            
            VStack(spacing: 0) {
                Text("LONGWOOD")
                    .font(.system(size: 35, weight: .bold, design: .serif))
                    .tracking(5)
                    .offset(x: isAnimating ? 0 : -UIScreen.main.bounds.width)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("CENTER for the")
                    .font(.system(size: 25, weight: .regular, design: .serif))
                    .italic()
                    .offset(y: isAnimating ? 0 : UIScreen.main.bounds.height)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("VISUAL ARTS")
                    .font(.system(size: 25, weight: .regular, design: .serif))
                    .italic()
                    .offset(x: isAnimating ? 0 : UIScreen.main.bounds.width)
                    .opacity(isAnimating ? 1 : 0)
            }
            .foregroundColor(.white)
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 1.8)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 1.2)) {
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isPresented = false
                }
            }
        }
    }
}

struct ContentView: View {
    let pastExhibitions = sampleExhibitions
    let activeExhibitions = currentExhibitions
    let sampleArtist = Artist(
        name: "Sun English Jr.",
        medium: "Sculpture",
        bio: "Sun English Jr. is a sculptor and performance artist known for immersive installations.",
        
        imageUrls: ["Black Front", "M1", "Poison I", "Poison II"],
        videos: ["small", "immure"]
    )
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var preferences: [String] = []
    
    @State private var isArtistDetailPresented = false

    @State private var selectedArtPiece: ArtPiece? = nil
    @State private var isAnimating = false
    @StateObject private var userManager = UserManager()
    @State private var recommendedArt: [ArtPiece] = [] // State to store mood-based recommendations
    @State private var selectedTab = 0

    @State private var selectedExhibition: Exhibition? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSplash = true
    
    @State private var hasScrolledToInitialPositionCurrent = false
    @State private var hasScrolledToInitialPositionPast = false
    @State private var hasScrolledToInitialPositionArtist = false
    @State private var hasScrolledToInitialPositionFeatured = false
    
    var body: some View {
        ZStack {
            NavigationView {
                TabView(selection: $selectedTab) {
                    // Home Tab
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        
                        // Content
                        ScrollView {
                            VStack {
                                // Add padding for notch/camera area
                                Color.clear
                                    .frame(height: 35)
                                
                                // Mood Input
                                MoodInputView(recommendedArt: $recommendedArt)
                                
                                // Info Accordion
                                InfoAccordionView()
                                    .padding(.bottom, 24)  // Add padding below Info Accordion
                                
                                // First row: Exhibitions
                                VStack(spacing: 24) {  // Increased spacing between sections
                                    // Current Shows Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Current Shows")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        ScrollViewReader { scrollProxy in
                                            HStack(spacing: 16) {  // Container for arrows and content
                                                // Left arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = max(currentIndex - 1, 0)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                                
                                                // ScrollView content
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 32) {
                                                        Spacer()
                                                            .frame(width: 120)
                                                        
                                                        ForEach(Array(activeExhibitions.enumerated()), id: \.element.id) { index, exhibition in
                                                            VStack(alignment: .leading, spacing: 4) {  // Reduced spacing
                                                                AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(width: 120, height: 120)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                        .shadow(radius: 2)
                                                                } placeholder: {
                                                                    ProgressView()
                                                                        .frame(width: 120, height: 120)
                                                                }
                                                                
                                                                VStack(alignment: .leading, spacing: 2) {  // Fixed text container
                                                                    Text(exhibition.title)
                                                                        .font(.caption)
                                                                        .bold()
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(3)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                    
                                                                    Text(exhibition.artist.count > 1 ? "Various Artists" : exhibition.artist[0])
                                                                        .font(.caption)
                                                                        .foregroundColor(.white.opacity(0.7))
                                                                        .lineLimit(3)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                }
                                                                .frame(height: 70)
                                                            }
                                                            .frame(width: 120)
                                                            .id(index)
                                                            .onTapGesture {
                                                                selectedExhibition = exhibition
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                            .frame(width: 120)
                                                    }
                                                    .padding(.horizontal, 8)
                                                }
                                                .task {
                                                    if !hasScrolledToInitialPositionCurrent {
                                                        try? await Task.sleep(nanoseconds: 100_000_000)
                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                            scrollProxy.scrollTo(0, anchor: .leading)
                                                        }
                                                        hasScrolledToInitialPositionCurrent = true
                                                    }
                                                }
                                                
                                                // Right arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = min(currentIndex + 1, activeExhibitions.count - 1)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Past Shows Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Past Shows")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        ScrollViewReader { scrollProxy in
                                            HStack(spacing: 16) {  // Container for arrows and content
                                                // Left arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = max(currentIndex - 1, 0)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                                
                                                // ScrollView content
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 32) {
                                                        Spacer()
                                                            .frame(width: 120)
                                                        
                                                        ForEach(Array(pastExhibitions.enumerated()), id: \.element.id) { index, exhibition in
                                                            VStack(alignment: .leading, spacing: 4) {
                                                                AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(width: 120, height: 120)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                        .shadow(radius: 2)
                                                                } placeholder: {
                                                                    ProgressView()
                                                                        .frame(width: 120, height: 120)
                                                                }
                                                                
                                                                VStack(alignment: .leading, spacing: 2) {
                                                                    Text(exhibition.title)
                                                                        .font(.caption)
                                                                        .bold()
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(3)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                    
                                                                    Text(exhibition.artist.count > 1 ? "Various Artists" : exhibition.artist[0])
                                                                        .font(.caption)
                                                                        .foregroundColor(.white.opacity(0.7))
                                                                        .lineLimit(3)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                }
                                                                .frame(height: 70)
                                                            }
                                                            .frame(width: 120)
                                                            .id(index)
                                                            .onTapGesture {
                                                                selectedExhibition = exhibition
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                            .frame(width: 120)
                                                    }
                                                    .padding(.horizontal, 8)
                                                }
                                                .task {
                                                    if !hasScrolledToInitialPositionPast {
                                                        try? await Task.sleep(nanoseconds: 100_000_000)
                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                            scrollProxy.scrollTo(0, anchor: .leading)
                                                        }
                                                        hasScrolledToInitialPositionPast = true
                                                    }
                                                }
                                                
                                                // Right arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = min(currentIndex + 1, pastExhibitions.count - 1)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    // Artist Spotlight Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Artist Spotlight")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        ScrollViewReader { scrollProxy in
                                            HStack(spacing: 16) {  // Container for arrows and content
                                                // Left arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = max(currentIndex - 1, 0)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                                
                                                // ScrollView content
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 32) {
                                                        Spacer()
                                                            .frame(width: 120)
                                                        
                                                        ForEach(Array(sampleArtist.imageUrls.enumerated()), id: \.element) { index, imageUrl in
                                                            VStack(alignment: .leading, spacing: 4) {
                                                                Image(imageUrl)
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: 120, height: 120)
                                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                    .shadow(radius: 2)
                                                                
                                                                VStack(alignment: .leading, spacing: 2) {
                                                                    Text(sampleArtist.name)
                                                                        .font(.caption)
                                                                        .bold()
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(2)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                    
                                                                    Text(sampleArtist.medium)
                                                                        .font(.caption)
                                                                        .foregroundColor(.white.opacity(0.7))
                                                                        .lineLimit(2)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                }
                                                                .frame(height: 60)
                                                            }
                                                            .frame(width: 120)
                                                            .id(index)
                                                        }
                                                        
                                                        Spacer()
                                                            .frame(width: 120)
                                                    }
                                                    .padding(.horizontal, 8)
                                                }
                                                .task {
                                                    if !hasScrolledToInitialPositionArtist {
                                                        try? await Task.sleep(nanoseconds: 100_000_000)
                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                            scrollProxy.scrollTo(0, anchor: .leading)
                                                        }
                                                        hasScrolledToInitialPositionArtist = true
                                                    }
                                                }
                                                
                                                // Right arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = min(currentIndex + 1, sampleArtist.imageUrls.count - 1)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        isArtistDetailPresented = true
                                    }
                                    .contentShape(Rectangle())
                                    .buttonStyle(PlainButtonStyle())
                                    .sheet(isPresented: $isArtistDetailPresented) {
                                        ArtistDetailModalView(artist: sampleArtist, isPresented: $isArtistDetailPresented)
                                    }
                                    
                                    // Featured Art Section
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Featured Art")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        ScrollViewReader { scrollProxy in
                                            HStack(spacing: 16) {  // Container for arrows and content
                                                // Left arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = max(currentIndex - 1, 0)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                                
                                                // ScrollView content
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 32) {
                                                        Spacer()
                                                            .frame(width: 120)
                                                        
                                                        ForEach(Array(featuredArtPieces.enumerated()), id: \.element.id) { index, artPiece in
                                                            VStack(alignment: .leading, spacing: 4) {
                                                                AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                                                                    image
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(width: 120, height: 120)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                        .shadow(radius: 2)
                                                                } placeholder: {
                                                                    ProgressView()
                                                                        .frame(width: 120, height: 120)
                                                                }
                                                                
                                                                VStack(alignment: .leading, spacing: 2) {
                                                                    Text(artPiece.title)
                                                                        .font(.caption)
                                                                        .bold()
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(3)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                    
                                                                    Text("Campus Art")
                                                                        .font(.caption)
                                                                        .foregroundColor(.white.opacity(0.7))
                                                                        .lineLimit(2)
                                                                        .frame(width: 120, alignment: .leading)
                                                                        .fixedSize(horizontal: false, vertical: true)
                                                                }
                                                                .frame(height: 60)
                                                            }
                                                            .frame(width: 120)
                                                            .id(index)
                                                            .onTapGesture {
                                                                selectedArtPiece = artPiece
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                            .frame(width: 120)
                                                    }
                                                    .padding(.horizontal, 8)
                                                }
                                                .task {
                                                    if !hasScrolledToInitialPositionFeatured {
                                                        try? await Task.sleep(nanoseconds: 100_000_000)
                                                        withAnimation(.easeOut(duration: 0.3)) {
                                                            scrollProxy.scrollTo(0, anchor: .leading)
                                                        }
                                                        hasScrolledToInitialPositionFeatured = true
                                                    }
                                                }
                                                
                                                // Right arrow
                                                Button(action: {
                                                    withAnimation {
                                                        let currentIndex = getCurrentIndex()
                                                        let newIndex = min(currentIndex + 1, featuredArtPieces.count - 1)
                                                        scrollProxy.scrollTo(newIndex, anchor: .center)
                                                    }
                                                }) {
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                        .background(Color.black.opacity(0.3))
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                // Hours above login
                                HoursAccordionView()
                                    .padding(.vertical)
                                
                                // Login at the bottom
                                UserAuthenticationView(userManager: userManager)
                            }
                        }
                    }
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    // Collection Tab
                    VStack {
                        ZStack {
                            // Background gradient
                            LinearGradient(
                                gradient: Gradient(colors: [Color.lcvaBlue, Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .ignoresSafeArea()
                            
                            // Existing content
                            VStack {
                                // Header with title and buttons
                                HStack {
                                    // User avatar/profile pic
                                    Circle()
                                        .fill(Color.white.opacity(0.3))  // Made lighter
                                        .frame(width: 35, height: 35)
                                    
                                    Text("Collections")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)  // Made white
                                    
                                    Spacer()
                                    
                                    // Search and Add buttons
                                    Button(action: { /* Search action */ }) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.white)  // Made white
                                    }
                                    .padding(.horizontal, 8)
                                    
                                    Button(action: { /* Add to collection action */ }) {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)  // Made white
                                    }
                                }
                                .padding(.horizontal)
                                
                                // Filter buttons
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(["Museum Collection", "Your Collection", "Favorites", "Artists"], id: \.self) { filter in
                                            Text(filter)
                                                .font(.subheadline)
                                                .foregroundColor(.white)  // Made white
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(Color.white.opacity(0.2))  // Made lighter
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Recent header with sort/view options
                                HStack {
                                    Text("Recents")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)  // Made white
                                    
                                    Spacer()
                                    
                                    // Grid view toggle
                                    Button(action: { /* Toggle view */ }) {
                                        Image(systemName: "square.grid.2x2")
                                            .foregroundColor(.white)  // Made white
                                    }
                                }
                                .padding()
                                
                                // Collection items
                                ScrollView {
                                    LazyVStack(spacing: 16) {
                                        ForEach(featuredArtPieces) { artPiece in
                                            HStack {
                                                // Artwork image
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
                                                
                                                // Artwork info
                                                VStack(alignment: .leading) {
                                                    Text(artPiece.title)
                                                        .font(.headline)
                                                        .foregroundColor(.white)  // Made white
                                                    Text("Museum Collection")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white.opacity(0.7))  // Made white with opacity
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            .onTapGesture {
                                                selectedArtPiece = artPiece
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tag(1)
                    .tabItem {
                        Label("Collections", systemImage: "line.3.horizontal")
                    }
                    
                    // Settings Tab
                    VStack {
                        ZStack {
                            // Background gradient
                            LinearGradient(
                                gradient: Gradient(colors: [Color.lcvaBlue, Color.white]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .ignoresSafeArea()
                            
                            ScrollView {
                                VStack(spacing: 20) {
                                    Text("Settings & ADA")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    DarkModeToggle()
                                        .padding(.horizontal)
                                    
                                    // Accessibility Assistance Section
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Accessibility")
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(.white)
                                        
                                        Text("Plan your visit with accommodations")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        AssistanceOptionButton(
                                            title: "Request Assistance",
                                            icon: "person.fill.checkmark",
                                            action: { /* Form is handled by the button */ }
                                        )
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    
                                    Divider()
                                        .background(.white)
                                        .padding(.vertical)
                                    
                                    // User Authentication Section
                                    if userManager.isLoggedIn {
                                        VStack(spacing: 16) {
                                            Text("Welcome, \(userManager.currentUser?.displayName ?? "User")!")
                                                .font(.title3)
                                                .bold()
                                                .foregroundColor(.white)
                                            
                                            Button("Log Out") {
                                                userManager.logOut()
                                            }
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .padding(.horizontal, 2)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(7)
                                            .shadow(radius: 2)
                                        }
                                    } else {
                                        VStack(spacing: 16) {
                                            TextField("Email", text: $email)
                                                .textFieldStyle(CustomTextFieldStyle())
                                            
                                            SecureField("Password", text: $password)
                                                .textFieldStyle(CustomTextFieldStyle())
                                            
                                            TextField("Name", text: $name)
                                                .textFieldStyle(CustomTextFieldStyle())
                                            
                                            HStack {
                                                Button("Log In") {
                                                    Task {
                                                        await userManager.logIn(email: email, password: password)
                                                        // Clear fields after successful login
                                                        email = ""
                                                        password = ""
                                                    }
                                                }
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .padding(4)
                                                .padding(.horizontal, 2)
                                                .background(Color.lcvaBlue)
                                                .cornerRadius(4)
                                                .shadow(radius: 2)

                                                Button("Sign Up") {
                                                    Task {
                                                        await userManager.signUp(email: email, password: password, name: name, preferences: preferences)
                                                        // Clear fields after successful signup
                                                        email = ""
                                                        password = ""
                                                        name = ""
                                                    }
                                                }
                                                .font(.system(size: 16))
                                                .foregroundColor(.white)
                                                .padding(4)
                                                .padding(.horizontal, 2)
                                                .background(Color.lcvaBlue.opacity(0.6))
                                                .cornerRadius(4)
                                                .shadow(radius: 2)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tag(2)
                    .tabItem {
                        Label("Settings & ADA", systemImage: "gear")
                    }
                }
                .onAppear {
                    // Set the tab bar background and styling
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                    tabBarAppearance.backgroundColor = UIColor(Color.lcvaNavy.opacity(0.2))
                    
                    // Configure item appearance for unselected state
                    tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white
                    tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont.systemFont(ofSize: 12)
                    ]
                    
                    // Add more padding at the top
                    tabBarAppearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
                    tabBarAppearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 4)
                    
                    // Selected state remains blue
                    tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.lcvaBlue)
                    tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                        .foregroundColor: UIColor(Color.lcvaBlue),
                        .font: UIFont.systemFont(ofSize: 12)
                    ]
                    
                    UITabBar.appearance().standardAppearance = tabBarAppearance
                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(Color.lcvaBlue)
            
            if showingSplash {
                SplashView(isPresented: $showingSplash)
                    .transition(.opacity)
            }
        }
        .sheet(item: $selectedExhibition) { exhibition in
            ExhibitionDetailModalView(
                exhibition: exhibition,
                isPresented: Binding(
                    get: { selectedExhibition != nil },
                    set: { if !$0 { selectedExhibition = nil } }
                )
            )
        }
    }

    private func formatDate(_ reception: String) -> String {
        // Split the string by commas
        let parts = reception.split(separator: ",")
        
        // Return the second part if it exists, trimmed of extra spaces
        return parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) + ", " + parts[2].trimmingCharacters(in: .whitespaces) : reception
    }

    private func getCurrentIndex() -> Int {
        // This is a simple implementation. You might want to add more sophisticated tracking
        // based on actual scroll position
        0
    }
}


// MARK: - Header View
struct HeaderView: View {
    @Binding var isAnimating: Bool

    var body: some View {
        VStack {
            Text("LONGWOOD")
                .font(.system(size: 35, weight: .bold, design: .serif))
                .tracking(5)
                .offset(y: isAnimating ? 0 : -100)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 1), value: isAnimating)

            Text("CENTER for the VISUAL ARTS")
                .font(.system(size: 25, weight: .regular, design: .serif))
                .italic()
                .offset(y: isAnimating ? 0 : -100)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeOut(duration: 1).delay(0.2), value: isAnimating)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(Color.primary)
        .padding(.bottom, 20)
        .onAppear {
            isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Current Exhibitions View
struct CurrentExhibitionsView: View {
    let exhibitions: [Exhibition]
    let colorScheme: ColorScheme

    @State private var slideInIndices: Set<Int> = [] // Track indices for sliding in
    @State private var loadedIndices: Set<Int> = [] // Track indices where images are loaded
    @State private var proxyExhibition: Exhibition? = nil
    @State private var selectedExhibition: Exhibition? // Track the selected exhibition
    @State private var isExhibitionDetailPresented = false // State to control modal presentation

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Current Exhibitions")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(.secondary)
                .padding(.bottom, 8)

            ForEach(Array(exhibitions.enumerated()), id: \.1.id) { index, exhibition in
                Button(action: {
                    proxyExhibition = exhibition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedExhibition = proxyExhibition
                        isExhibitionDetailPresented = true
                    }
                }) {
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .shadow(radius: 3)
                                .onAppear {
                                    loadedIndices.insert(index) // Mark this image as loaded
                                    triggerSlideIn(index) // Start slide-in if image is loaded
                                }
                        } placeholder: {
                            ProgressView()
                        }

                        VStack(alignment: .center, spacing: 4) {
                            Text(exhibition.title)
                                .font(.headline)
                                .padding(.bottom, 4)

                            Text(exhibition.artist.joined(separator: ", "))
                                .font(.subheadline)
                                .italic()
                                .bold()

                            Text("Reception:")
                                .font(.caption)
                                .padding(.top, 6)
                                .bold()
                                .accessibilityLabel(Text("Reception: \(exhibition.reception)"))
                            Text(formatDate(exhibition.reception))
                                .font(.caption)
                                
                                
                                .accessibilityLabel(Text("Reception: \(exhibition.reception)"))
                            Text(formatTime(exhibition.reception))
                                .font(.caption)


                            Text("Closing:")
                                .font(.caption)
                                
                                .bold()
                                .accessibilityLabel(Text("Reception: \(exhibition.closing)"))
                            Text(formatDate(exhibition.closing))
                                .font(.caption)
                                
                                .accessibilityLabel(Text("Closing: \(exhibition.closing)"))
                            
                            Text(formatTime(exhibition.closing))
                                .font(.caption)
                                .padding(.bottom, 8)
                                .accessibilityLabel(Text("Closing: \(exhibition.closing)"))

                            Link("Survey Link", destination: URL(string: exhibition.surveyUrl)!)
                                .font(.caption)
                                .padding(2)
                                .padding(.horizontal, 2)
                                .background(Color.primary.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(3)
                                .shadow(radius: 2)
                        }
                        .frame(width: 190)
                    }
                    .padding()
                    .frame(maxWidth: 400)
                    .background(
                        RoundedRectangle(cornerRadius: 7)
                            .fill(colorScheme == .dark ? Color.lcvaNavy.opacity(0.9) : .white)
                            .shadow(radius: 3)
                    )
                    .offset(x: slideInIndices.contains(index) ? 0 : -UIScreen.main.bounds.width) // Slide-in from left
                    .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.2), value: slideInIndices)
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(.primary)
        .sheet(isPresented: Binding(
            get: { selectedExhibition != nil },
            set: { newValue in
                if !newValue { selectedExhibition = nil }
            }
        )) {
            if let exhibition = selectedExhibition {
                ExhibitionDetailModalView(exhibition: exhibition, isPresented: Binding(
                    get: { selectedExhibition != nil },
                    set: { newValue in
                        if !newValue { selectedExhibition = nil }
                    }
                ))
//                .presentationDetents([.medium]) // Ensure compact modal style
//                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func formatDate(_ reception: String) -> String {
        // Split the string by commas
        let parts = reception.split(separator: ",")
        
        // Return the second part if it exists, trimmed of extra spaces
        return parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) + ", " + parts[2].trimmingCharacters(in: .whitespaces) : reception
    }

    private func formatTime(_ reception: String) -> String {
        // Split by commas and safely handle the parts
        let parts = reception.split(separator: ",")
        
        // If we have enough parts, get the time portion
        if parts.count >= 2 {
            // Get the last part which should contain the time
            let timePart = parts.last?.trimmingCharacters(in: .whitespaces) ?? ""
            return timePart
        }
        
        // If we can't parse it, return the original string
        return reception
    }
    /// Trigger slide-in animation only if the image has loaded
    private func triggerSlideIn(_ index: Int) {
        if loadedIndices.contains(index) {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                slideInIndices.insert(index)
            }
        }
    }
}

    





// MARK: - Featured Artist View
struct FeaturedArtistView: View {
    let sampleArtist: Artist
    let colorScheme: ColorScheme
    @State private var isArtistDetailPresented = false
    @State private var slideInOffset: CGFloat = -UIScreen.main.bounds.width

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Artist Spotlight")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            ArtistInfoView(name: sampleArtist.name)
            ImageGalleryView(imageUrls: sampleArtist.imageUrls)
            LearnMoreButton(sampleArtist: sampleArtist, isArtistDetailPresented: $isArtistDetailPresented)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.lcvaNavy.opacity(0.6))
                .shadow(radius: 3)
        )
        .frame(maxWidth: 400)
        .padding(.horizontal)
        .offset(x: slideInOffset)
        .onAppear {
            withAnimation(.easeOut(duration: 1.3).delay(1)) {
                slideInOffset = 0
            }
        }
        .sheet(isPresented: $isArtistDetailPresented) {
            ArtistDetailModalView(artist: sampleArtist, isPresented: $isArtistDetailPresented)
        }
    }

    private struct ArtistInfoView: View {
        let name: String
        var body: some View {
            Text(name)
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
    }

    private class ImagePresentationModel: ObservableObject {
        @Published var selectedImage: String?
        @Published var isPresenting = false
        
        func presentImage(_ imageUrl: String) {
            selectedImage = imageUrl
            isPresenting = true
        }
        
        func dismissImage() {
            isPresenting = false
            selectedImage = nil
        }
    }

    private struct ImageGalleryView: View {
        let imageUrls: [String]
        @StateObject private var presentationModel = ImagePresentationModel()
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(imageUrls.prefix(3), id: \.self) { imageUrl in
                        Image(imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Rectangle())
                            .padding(.vertical, 5)
                            .shadow(radius: 3)
                            .onTapGesture {
                                presentationModel.presentImage(imageUrl)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .fullScreenCover(isPresented: $presentationModel.isPresenting) {
                if let selectedImage = presentationModel.selectedImage {
                    EnlargedImageView(
                        imageUrl: selectedImage,
                        isPresented: $presentationModel.isPresenting
                    )
                }
            }
        }
    }

    private struct EnlargedImageView: View {
        let imageUrl: String
        @Binding var isPresented: Bool
        @State private var scale: CGFloat = 1.0
        @GestureState private var gestureScale: CGFloat = 1.0
        
        var body: some View {
            NavigationView {
                GeometryReader { geometry in
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        Image(imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width)
                            .frame(maxHeight: geometry.size.height)
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

    private struct LearnMoreButton: View {
        let sampleArtist: Artist
        @Binding var isArtistDetailPresented: Bool
        
        var body: some View {
            Button(action: {
                isArtistDetailPresented = true
            }) {
                Text("More Info")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(4)
                    .padding(.horizontal, 2)
                    .background(Color.lcvaBlue)
                    .cornerRadius(4)
                    .shadow(radius: 2)
            }
        }
    }
}


// MARK: - Featured Art on Campus View
struct FeaturedArtOnCampusView: View {
    let colorScheme: ColorScheme
    @Binding var selectedArtPiece: ArtPiece?

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Featured Art on Campus")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(featuredArtPieces) { artPiece in
                        ArtPieceCard(artPiece: artPiece, selectedArtPiece: $selectedArtPiece)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.lcvaNavy.opacity(0.6))
                .shadow(radius: 3)
        )
        .frame(maxWidth: 400)
        .padding(.horizontal)
        .sheet(item: $selectedArtPiece) { artPiece in
            NavigationView {
                MapModalView(artPiece: artPiece, userManager: UserManager())
            }
        }
    }
}

// MARK: - User Authentication View
struct UserAuthenticationView: View {
    @ObservedObject var userManager: UserManager
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var preferences: [String] = []

    var body: some View {
        VStack {
            if userManager.isLoggedIn {
                Text("Welcome, \(userManager.currentUser?.displayName ?? "User")!")
                
                Button("Log Out") {
                    userManager.logOut()
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(4)
                .padding(.horizontal, 2)
                
                .background(Color.primary.opacity(0.2))
                
                .cornerRadius(7)
                .shadow(radius: 2)
            } else {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(14)
                    .shadow(radius: 5)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(14)
                    .shadow(radius: 5)

                TextField("Name", text: $name)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(14)
                    .shadow(radius: 5)

                HStack {
                    Button("Log In") {
                        Task {
                            await userManager.logIn(email: email, password: password)
                            // Clear fields after successful login
                            email = ""
                            password = ""
                        }
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(4)
                    .padding(.horizontal, 2)
                    .background(Color.lcvaBlue)
                    .cornerRadius(4)
                    .shadow(radius: 2)

                    Button("Sign Up") {
                        Task {
                            await userManager.signUp(email: email, password: password, name: name, preferences: preferences)
                            // Clear fields after successful signup
                            email = ""
                            password = ""
                            name = ""
                        }
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(4)
                    .padding(.horizontal, 2)
                    .background(Color.lcvaBlue.opacity(0.6))
                    .cornerRadius(4)
                    .shadow(radius: 2)
                }
            }
        }
        .padding()
        .frame(maxWidth: 420)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


    // Separate view for VideoPlayer to manage AVPlayer setup
    struct VideoPlayerView: View {
        let videoName: String

        var body: some View {
            if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: url))
                    .scaledToFit()
            } else {
                Text("Video not found")
                    .foregroundColor(.red)
            }
        }
    }

// First, add the ArtPieceCard view
private struct ArtPieceCard: View {
    let artPiece: ArtPiece
    @Binding var selectedArtPiece: ArtPiece?
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                image
                    .resizable()
                    .frame(width: 150, height: 150)
                    .clipShape(Rectangle())
                    .shadow(radius: 3)
                    .onTapGesture {
                        selectedArtPiece = artPiece
                    }
            } placeholder: {
                ProgressView()
            }
            
            Text(artPiece.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)

            Text(artPiece.description)
                .font(.subheadline)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
        }
        .padding()
    }
}

// Add this custom text field style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(14)
            .shadow(radius: 5)
    }
}

// First, add this helper view
struct ScrollArrowIndicators: View {
    var body: some View {
        HStack {
            // Left arrow
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .opacity(0.6)
                .padding(8)
                .background(Color.black.opacity(0.2))
                .clipShape(Circle())
            
            Spacer()
            
            // Right arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .opacity(0.6)
                .padding(8)
                .background(Color.black.opacity(0.2))
                .clipShape(Circle())
        }
        .padding(.horizontal, 4)
    }
}



