import SwiftUI
import MapKit

struct MapModalView: View {
    let artPiece: ArtPiece
    @ObservedObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    @State private var shouldReloadMap = true  // Set to true by default

    var body: some View {
        NavigationView {
            ScrollView {
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

                    // Map view without conditional rendering
                    MapViewRepresentable(artPiece: artPiece)
                        .frame(height: 300)  // Made map taller
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 3)
                        .padding()

//                    Divider()
//                        .padding(.horizontal)

                    // Display chat view
//                    Text("Share your thoughts with your peers:")
//                        .font(.system(size: 12))
//                        .padding(2)

//                    ChatView(artPieceID: artPiece.id, userManager: userManager)
//                        .frame(maxHeight: 380)
//                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle(artPiece.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

