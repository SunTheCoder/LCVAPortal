import Foundation

class UserCollections: ObservableObject {
    @Published var personalCollection: [ArtPiece] = []
    @Published var favorites: [ArtPiece] = []
    
    func addToCollection(_ artPiece: ArtPiece) {
        if !personalCollection.contains(where: { $0.id == artPiece.id }) {
            personalCollection.append(artPiece)
        }
    }
    
    func removeFromCollection(_ artPiece: ArtPiece) {
        personalCollection.removeAll { $0.id == artPiece.id }
    }
    
    func toggleFavorite(_ artPiece: ArtPiece) {
        if favorites.contains(where: { $0.id == artPiece.id }) {
            favorites.removeAll { $0.id == artPiece.id }
        } else {
            favorites.append(artPiece)
        }
    }
    
    func isInCollection(_ artPiece: ArtPiece) -> Bool {
        personalCollection.contains(where: { $0.id == artPiece.id })
    }
    
    func isFavorite(_ artPiece: ArtPiece) -> Bool {
        favorites.contains(where: { $0.id == artPiece.id })
    }
} 