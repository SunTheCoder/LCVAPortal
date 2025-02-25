import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    let artPieces: [ArtPiece]
    let userCollections: UserCollections
    let userManager: UserManager
    
    var filteredArtPieces: [ArtPiece] {
        if searchText.isEmpty {
            return []
        } else {
            return artPieces.filter { piece in
                piece.title.localizedCaseInsensitiveContains(searchText) ||
                piece.description.localizedCaseInsensitiveContains(searchText) ||
                piece.material.localizedCaseInsensitiveContains(searchText) ||
                piece.era.localizedCaseInsensitiveContains(searchText) ||
                piece.origin.localizedCaseInsensitiveContains(searchText)
            }
        }
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
