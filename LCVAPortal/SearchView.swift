import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    let artPieces: [ArtPiece]
    @ObservedObject var userCollections: UserCollections
    @ObservedObject var userManager: UserManager
    
    var filteredArtPieces: [ArtPiece] {
        if searchText.isEmpty {
            return artPieces
        } else {
            return artPieces.filter { artPiece in
                artPiece.title.localizedCaseInsensitiveContains(searchText) ||
                artPiece.description.localizedCaseInsensitiveContains(searchText) ||
                artPiece.material.localizedCaseInsensitiveContains(searchText) ||
                artPiece.era.localizedCaseInsensitiveContains(searchText) ||
                artPiece.origin.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func isInCollection(_ artPiece: ArtPiece) -> Bool {
        userCollections.isInCollection(artPiece)
    }
    
    func isFavorite(_ artPiece: ArtPiece) -> Bool {
        userCollections.isFavorite(artPiece)
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
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
                .padding()
                
                // Results
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredArtPieces) { artPiece in
                            NavigationLink(destination: ArtDetailView(
                                artPiece: artPiece,
                                userManager: userManager,
                                userCollections: userCollections
                            )) {
                                HStack {
                                    AsyncImage(url: SupabaseClient.shared.getTransformedImageUrl(
                                        artPiece.imageUrl,
                                        options: TransformOptions(
                                            width: 60,
                                            height: 60,
                                            resize: "cover",
                                            quality: 85
                                        )
                                    )) { image in
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
                                        Text(artPiece.material)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
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

