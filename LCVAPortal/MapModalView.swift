import SwiftUI
import MapKit

struct MapModalView: View {
    let artPiece: ArtPiece
    @ObservedObject var userManager: UserManager // Add userManager parameter

    @State private var shouldReloadMap = false

    var body: some View {
       
            ScrollView { // Wrap content in a ScrollView
                VStack(alignment: .center, spacing: 16) {
                    // Display the art piece image
                    AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 350, maxHeight: 350)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .shadow(radius: 3)
                    } placeholder: {
                        ProgressView()
                    }

                    // Display the description
                    Text(artPiece.description)
                        .font(.system(size: 14))
                        .padding()

                    // Display the map view
                    if shouldReloadMap {
                        MapViewRepresentable(artPiece: artPiece)
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(radius: 3)
                            .padding()
                    }

                    Divider()
                        .padding(.horizontal)

                    // Display chat view
                    Text("Share your thoughts with your peers:")
                        .font(.system(size: 12))
                        .padding(2)

                    ChatView(artPieceID: artPiece.id, userManager: userManager)
                        .frame(maxHeight: 380)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle(artPiece.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    shouldReloadMap = true
                }
            }
        }
    }

