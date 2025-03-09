import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @EnvironmentObject var artifactManager: ArtifactManager
    @ObservedObject var userCollections: UserCollections
    @ObservedObject var userManager: UserManager
    @State private var isSearching = false
    @State private var debounceTimer: Timer?
    
    var filteredArtPieces: [ArtPiece] {
        let normalizedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalizedQuery.isEmpty {
            return artifactManager.artifacts.map(convertToArtPiece)
        } else {
            // Split search terms
            let searchTerms = normalizedQuery.split(separator: " ")
            
            return artifactManager.artifacts.filter { artifact in
                // Create array of searchable fields
                let searchableFields = [
                    artifact.title,
                    artifact.description,
                    artifact.artist,
                    artifact.gallery,
                    artifact.collection,
                    artifact.location
                ].compactMap { $0?.lowercased() }
                
                // All search terms must match at least one field
                return searchTerms.allSatisfy { term in
                    searchableFields.contains { field in
                        field.contains(term)
                    }
                }
            }.map(convertToArtPiece)
        }
    }
    
    private func convertToArtPiece(_ artifact: Artifact) -> ArtPiece {
        ArtPiece(
            id: artifact.id,
            title: artifact.title,
            artist: artifact.artist,
            description: artifact.description ?? "",
            imageUrl: artifact.image_url ?? "",
            latitude: 0.0,
            longitude: 0.0,
            material: artifact.gallery ?? "",
            era: "",
            origin: "",
            lore: "",
            translations: nil,
            audioTour: nil,
            brailleLabel: nil,
            adaAccessibility: nil
        )
    }
    
    private func performSearch() {
        // Cancel any existing timer
        debounceTimer?.invalidate()
        
        // Create new timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            isSearching = !searchText.isEmpty
            // Here you could add server-side search if needed
        }
    }
    
    func isInCollection(_ artPiece: ArtPiece) -> Bool {
        userCollections.isInCollection(artPiece)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("Search art pieces...", text: $searchText)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) { _ in
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            isSearching = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    if isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
                .padding()
                
                // Results
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(filteredArtPieces) { artPiece in
                            NavigationLink(destination: ArtDetailView(
                                artPiece: artPiece,
                                userManager: userManager,
                                userCollections: userCollections
                            )) {
                                VStack {
                                    CachedArtifactsGridView(
                                        urlString: artPiece.imageUrl,
                                        filename: URL(string: artPiece.imageUrl)?.lastPathComponent ?? ""
                                    )
                                    .frame(height: 100)
                                    
                                    Text(artPiece.title)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(artPiece.artist)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        
                                }
                                .padding()
                                .cornerRadius(4)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
    }
} 

