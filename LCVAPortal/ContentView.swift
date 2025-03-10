import SwiftUI
import AVKit

extension Color {
    static let lcvaNavy = Color(red: 13/255, green: 27/255, blue: 62/255)  // Dark navy
    static let lcvaBlue = Color(red: 52/255, green: 144/255, blue: 220/255)  // Lighter blue
}

struct SplashView: View {
    @Binding var isPresented: Bool
    @ObservedObject var preloadManager = PreloadManager.shared
    @State private var isAnimating = false
    @State private var opacity: CGFloat = 1
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
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
            
            // Wait for both animation and preloading
            Task {
                // Wait minimum time for animation
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                
                // Wait for preloading if it's not done
                await waitForPreload()
                
                withAnimation(.easeOut(duration: 1.2)) {
                    opacity = 0
                }
                
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                isPresented = false
            }
        }
    }
    
    private func waitForPreload() async {
        while preloadManager.isLoading {
            try? await Task.sleep(nanoseconds: 100_000_000) // Check every 0.1 seconds
        }
    }
}

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var preferences: [String] = []
    
    @State private var isArtistDetailPresented = false

    @State private var selectedArtPiece: ArtPiece? = nil
    @State private var isAnimating = false
    @StateObject private var userManager: UserManager
    @StateObject private var userCollections = UserCollections()
    @State private var recommendedArt: [ArtPiece] = [] // State to store mood-based recommendations
    @State private var selectedTab = 0

    @State private var selectedExhibition: Exhibition? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSplash = true
    
    @State private var hasScrolledToInitialPositionCurrent = false
    @State private var hasScrolledToInitialPositionPast = false
    @State private var hasScrolledToInitialPositionArtist = false
    @State private var hasScrolledToInitialPositionFeatured = false
    
    @State private var longPressedExhibitionId: UUID? = nil
    
    // Add state for Supabase data
    @State private var artifacts: [Artifact] = []
    @State private var isLoading = false
    @State private var error: String?
    
    // Convert Supabase Artifact to ArtPiece
    private func convertToArtPiece(_ artifact: Artifact) -> ArtPiece {
        ArtPiece(
            id: artifact.id,
            title: artifact.title,
            artist: artifact.artist,
            description: artifact.description ?? "",
            imageUrl: artifact.image_url ?? "",
            latitude: 0.0,
            longitude: 0.0,
            material: artifact.gallery ?? "Unknown",
            era: "",
            origin: "",
            lore: "",
            translations: nil,
            audioTour: nil,
            brailleLabel: nil,
            adaAccessibility: nil
        )
    }
    
    // Get featured artifacts
    var featuredArtPieces: [ArtPiece] {
        artifacts
            .filter { $0.featured }  // Use the featured column
            .map(convertToArtPiece)
    }
    
    private func fetchArtifacts() {
        Task {
            isLoading = true
            do {
                let fetchedArtifacts = try await SupabaseClient.shared.fetchArtifacts()
                await MainActor.run {
                    self.artifacts = fetchedArtifacts
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    init() {
        // Create UserManager with reference to UserCollections
        let collections = UserCollections()
        _userCollections = StateObject(wrappedValue: collections)
        _userManager = StateObject(wrappedValue: UserManager(userCollections: collections))
    }
    
    var body: some View {
        ZStack {
        NavigationView {
                TabView(selection: $selectedTab) {
                    // Home Tab
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
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
                                    .padding(.bottom, 12)  // Reduced padding between accordions
                                
                            
                                
                                // First row: Exhibitions
                                VStack(spacing: 24) {  
                                    CurrentShowsView(
                                        hasScrolledToInitialPositionCurrent: $hasScrolledToInitialPositionCurrent
                                    )
                                    
                                    PastShowsView(
                                        hasScrolledToInitialPositionPast: $hasScrolledToInitialPositionPast
                                    )
                                    
                                    // Featured Art Section
                                    FeaturedArtSection(
                                        featuredArtPieces: featuredArtPieces,
                                        userManager: userManager,
                                        userCollections: userCollections
                                    )
                                    .padding(.bottom, 8)  
                                    
                                    ArtistSpotlightView()
                                    .padding(.top, 16)
                                    .padding(.bottom, 26)

                                }
                                .padding(.horizontal)
                                .padding(.vertical)
                                
                                
                                
                    

                                HoursAccordionView()
                                    .padding(.vertical)

                                MuseumInfoAccordionView(userManager: userManager)
                                    .padding(.vertical)
                    
                                UserAuthenticationView(userManager: userManager)
                            }
                        }
                    }
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    // Collections Tab
                    CollectionsView(selectedArtPiece: $selectedArtPiece, userManager: userManager)
                        .tabItem {
                            Label("Collections", systemImage: "line.3.horizontal")
                        }
                        .tag(1)
                    
                    // Settings Tab
                    VStack {
                        ZStack {
                            // Background gradient
                            LinearGradient(
                                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
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
                                    
                                    // Clear Cache Button
                                    VStack(alignment: .leading, spacing: 8) {
                                        Button(action: {
                                            showClearCacheAlert = true
                                        }) {
                                            HStack {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                Text("Clear Media Cache")
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text(formatCacheSize())
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                        .alert("Clear Cache?", isPresented: $showClearCacheAlert) {
                                            Button("Cancel", role: .cancel) { }
                                            Button("Clear", role: .destructive) {
                                                clearCache()
                                            }
                                        } message: {
                                            Text("This will free up \(formatCacheSize()) of space.")
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    // DarkModeToggle()
                                    //     .padding(.horizontal)
                                    
                                    // Accessibility Assistance Section
                                    // VStack(alignment: .leading, spacing: 8) {
                                    //     Text("Accessibility")
                                    //         .font(.headline)
                                    //         .bold()
                                    //         .foregroundColor(.white)
                                        
                                    //     Text("Plan your visit with accommodations")
                                    //         .font(.subheadline)
                                    //         .foregroundColor(.white.opacity(0.7))
                                        
                                    //     AssistanceOptionButton(
                                    //         title: "Request Assistance",
                                    //         icon: "person.fill.checkmark",
                                    //         action: { /* Form is handled by the button */ }
                                    //     )
                                    // }
                                    // .padding()
                                    // .background(Color.white.opacity(0.1))
                                    // .cornerRadius(10)
                                    // .padding(.horizontal)
                                    
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
                                                        do {
                                                            // Clear fields after successful signup
                                                            try await userManager.signUp(email: email, password: password, name: name, preferences: preferences)
                                                            email = ""
                                                            password = ""
                                                            name = ""
                                                        } catch {
                                                            // Handle error - you might want to show this to the user
                                                            print("Sign up error:", error.localizedDescription)
                                                        }
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
            ExhibitionDetailView(
                exhibition: exhibition
            )
        }
        .onAppear {
            fetchArtifacts()
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

    @State private var showClearCacheAlert = false
    @State private var showClearCacheSuccess = false
    
    private func formatCacheSize() -> String {
        let imageSize = ImageCache.shared.getCacheSize()
        return ByteCountFormatter.string(fromByteCount: imageSize, countStyle: .file)
    }
    
    private func clearCache() {
        ImageCache.shared.clearCache()
        VideoCache.shared.clearCache()
        showClearCacheSuccess = true
        
        // Hide success message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showClearCacheSuccess = false
        }
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

    @State private var slideInIndices: Set<Int> = []
    @State private var loadedIndices: Set<Int> = []
    @State private var proxyExhibition: Exhibition? = nil
    @State private var selectedExhibition: Exhibition? 
    @State private var isExhibitionDetailPresented = false

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
                        AsyncImage(url: URL(string: exhibition.image_url ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .shadow(radius: 3)
                                .onAppear {
                                    loadedIndices.insert(index)
                                    triggerSlideIn(index)
                                }
                        } placeholder: {
                            ProgressView()
                        }

                        VStack(alignment: .center, spacing: 4) {
                            Text(exhibition.name)
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
                            Text(exhibition.start_date)
                                .font(.caption)
                                .accessibilityLabel(Text("Reception: \(exhibition.start_date)"))
                                
                            Text(exhibition.start_date)
                                .font(.caption)

                            Text("Closing:")
                                .font(.caption)
                                .bold()
                            Text(exhibition.end_date)
                                .font(.caption)
                                .accessibilityLabel(Text("Closing: \(exhibition.end_date)"))
                                
                            Text(exhibition.end_date)
                                .font(.caption)
                                .padding(.bottom, 8)

                            if let surveyUrl = exhibition.survey_url, let url = URL(string: surveyUrl) {
                                Link("Survey Link", destination: url)
                                .font(.caption)
                                .padding(2)
                                .padding(.horizontal, 2)
                                .background(Color.primary.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(3)
                                .shadow(radius: 2)
                            }
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
                    .offset(x: slideInIndices.contains(index) ? 0 : -UIScreen.main.bounds.width)
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
                ExhibitionDetailView(exhibition: exhibition)
            }
        }
    }
    

   
    
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
                            do {
                                // Clear fields after successful signup
                                try await userManager.signUp(email: email, password: password, name: name, preferences: preferences)
                                email = ""
                                password = ""
                                name = ""
                            } catch {
                                // Handle error - you might want to show this to the user
                                print("Sign up error:", error.localizedDescription)
                            }
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

//// Create a placeholder view for Tours & Education
//struct ToursEducationView: View {
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Use the same gradient background as Collections
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                VStack {
//                    Text("Tours & Education")
//                        .font(.title)
//                        .foregroundColor(.white)
//                    Text("Coming Soon")
//                        .foregroundColor(.white.opacity(0.7))
//                }
//            }
//        }
//    }
//}
//

// Featured Art Section
// struct FeaturedArtSection: View {  // Create a separate view
//     @State private var featuredArtIndex = 0  // State at struct level
//     let featuredArtPieces: [ArtPiece]
//     let userManager: UserManager
//     let userCollections: UserCollections
    
//     var body: some View {
//         VStack(alignment: .leading, spacing: 12) {
//             Text("Featured Art")
//                 .font(.system(size: 18))
//                 .bold()
//                 .foregroundColor(.white)
            
//             ScrollViewReader { scrollProxy in
//                 HStack(spacing: 16) {
//                     // Left arrow
//                     Button(action: {
//                         withAnimation {
//                             featuredArtIndex = max(featuredArtIndex - 1, 0)
//                             scrollProxy.scrollTo(featuredArtIndex, anchor: .center)
//                         }
//                     }) {
//                         Image(systemName: "chevron.left")
//                             .foregroundColor(.white)
//                             .opacity(featuredArtIndex == 0 ? 0.3 : 1)  // Fade when disabled
//                             .padding(8)
//                             .background(Color.black.opacity(0.3))
//                             .clipShape(Circle())
//                     }
//                     .disabled(featuredArtIndex == 0)
                    
//                     // ScrollView content
//                     ScrollView(.horizontal, showsIndicators: false) {
//                         HStack(spacing: 32) {
//                             ForEach(Array(featuredArtPieces.enumerated()), id: \.element.id) { index, artPiece in
//                                 VStack(alignment: .leading, spacing: 4) {
//                                     AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
//                                         NavigationLink(destination: ArtDetailView(
//                                             artPiece: artPiece,
//                                             userManager: userManager,
//                                             userCollections: userCollections
//                                         )) {
//                                             image
//                                                 .resizable()
//                                                 .scaledToFill()
//                                                 .frame(width: 120, height: 120)
//                                                 .clipShape(RoundedRectangle(cornerRadius: 8))
//                                                 .shadow(radius: 2)
//                                         }
//                                     } placeholder: {
//                                         ProgressView()
//                                             .frame(width: 120, height: 120)
//                                     }
                                    
//                                     VStack(alignment: .leading, spacing: 2) {
//                                         Text(artPiece.title)
//                                             .font(.caption)
//                                             .bold()
//                                             .foregroundColor(.white)
//                                             .lineLimit(3)
//                                             .frame(width: 120, alignment: .leading)
//                                             .fixedSize(horizontal: false, vertical: true)
                                        
//                                         Text("Campus Art")
//                                             .font(.caption)
//                                             .foregroundColor(.white.opacity(0.7))
//                                             .lineLimit(2)
//                                             .frame(width: 120, alignment: .leading)
//                                             .fixedSize(horizontal: false, vertical: true)
//                                     }
//                                     .frame(height: 60)
//                                 }
//                                 .frame(width: 120)
//                                 .id(index)
//                             }
//                         }
//                         .padding(.horizontal, 8)
//                     }
//                     .onChange(of: featuredArtIndex) { newIndex in
//                         withAnimation {
//                             scrollProxy.scrollTo(newIndex, anchor: .center)
//                         }
//                     }
                    
//                     // Right arrow
//                     Button(action: {
//                         withAnimation {
//                             let maxIndex = featuredArtPieces.count - 1
//                             featuredArtIndex = min(featuredArtIndex + 1, maxIndex)
//                             scrollProxy.scrollTo(featuredArtIndex, anchor: .center)
//                         }
//                     }) {
//                         Image(systemName: "chevron.right")
//                             .foregroundColor(.white)
//                             .opacity(featuredArtIndex == featuredArtPieces.count - 1 ? 0.3 : 1)  // Fade when disabled
//                             .padding(8)
//                             .background(Color.black.opacity(0.3))
//                             .clipShape(Circle())
//                     }
//                     .disabled(featuredArtIndex == featuredArtPieces.count - 1)
//                 }
//             }
//         }
//         .padding(.horizontal, 16)
//         .frame(maxWidth: .infinity)
//     }
// }

// Artist Spotlight Section
struct ArtistSpotlightSection: View {
    @State private var artistSpotlightIndex = 0
    let sampleArtist: Artist
    @Binding var isArtistDetailPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Artist Spotlight")
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.white)
            
            ScrollViewReader { scrollProxy in
                HStack(spacing: 16) {
                    // Left arrow
                    Button(action: {
                        withAnimation {
                            artistSpotlightIndex = max(artistSpotlightIndex - 1, 0)
                            scrollProxy.scrollTo(artistSpotlightIndex, anchor: .center)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .opacity(artistSpotlightIndex == 0 ? 0.3 : 1)  // Fade when disabled
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(artistSpotlightIndex == 0)
                    
                    // ScrollView content
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 32) {
                            ForEach(Array(sampleArtist.imageUrls.enumerated()), id: \.element) { index, imageUrl in
                                VStack(alignment: .leading, spacing: 4) {
                                    NavigationLink(destination: ArtistDetailView(artist: sampleArtist)) {
                                        Image(imageUrl)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .shadow(radius: 2)
                                    }
                                    
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
                                    .frame(height: 70)
                                }
                                .frame(width: 120)
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .onChange(of: artistSpotlightIndex) { newIndex in
                        withAnimation {
                            scrollProxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                    
                    // Right arrow
                    Button(action: {
                        withAnimation {
                            let maxIndex = sampleArtist.imageUrls.count - 1
                            artistSpotlightIndex = min(artistSpotlightIndex + 1, maxIndex)
                            scrollProxy.scrollTo(artistSpotlightIndex, anchor: .center)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .opacity(artistSpotlightIndex == sampleArtist.imageUrls.count - 1 ? 0.3 : 1)  // Fade when disabled
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(artistSpotlightIndex == sampleArtist.imageUrls.count - 1)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}


