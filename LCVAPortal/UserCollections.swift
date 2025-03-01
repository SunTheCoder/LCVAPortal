import Foundation

class UserCollections: ObservableObject {
    @Published var personalCollection: [ArtPiece] = []
    @Published var favorites: [ArtPiece] = []
    private let supabase = SupabaseClient.shared
    
    private var personalCollectionId: UUID?
    private var favoritesCollectionId: UUID?
    
    // Single method to handle both initialization and loading
    func loadUserCollections(userId: String) async {
        print("🔄 Loading collections for user: \(userId)")
        do {
            // First try to fetch existing collections
            let collections = try await supabase.fetchUserCollections(userId: userId)
            print("📦 Fetched collections: \(collections)")
            
            if collections.isEmpty {
                print("⚠️ No collections found, creating new ones...")
                // No collections exist - create them
                let (personal, favorites) = try await supabase.createUserCollections(userId: userId)
                self.personalCollectionId = personal
                self.favoritesCollectionId = favorites
                print("✅ Created collections - Personal: \(personal), Favorites: \(favorites)")
                
                // Initialize empty collections
                await MainActor.run {
                    self.personalCollection = []
                    self.favorites = []
                }
            } else {
                print("📚 Found existing collections")
                // Collections exist - load their artifacts
                if let personal = collections.first(where: { $0.name == "Personal" }) {
                    self.personalCollectionId = personal.id
                    print("🎨 Loading personal collection: \(personal.id)")
                    let artifacts = try await supabase.fetchCollectionArtifacts(collectionId: personal.id)
                    await MainActor.run {
                        self.personalCollection = artifacts.map(convertToArtPiece)
                    }
                }
                
                if let favorites = collections.first(where: { $0.name == "Favorites" }) {
                    self.favoritesCollectionId = favorites.id
                    print("⭐️ Loading favorites collection: \(favorites.id)")
                    let artifacts = try await supabase.fetchCollectionArtifacts(collectionId: favorites.id)
                    await MainActor.run {
                        self.favorites = artifacts.map(convertToArtPiece)
                    }
                }
            }
        } catch {
            print("❌ Failed to load user collections: \(error)")
        }
    }
    
    // Helper to convert Supabase Artifact to ArtPiece
    private func convertToArtPiece(_ artifact: Artifact) -> ArtPiece {
        return ArtPiece(
            id: artifact.id,
            title: artifact.title,
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
    
    // Local methods for immediate UI updates
    func addToCollection(_ artPiece: ArtPiece) {
        print("➕ Adding to collection: \(artPiece.id)")
        if !personalCollection.contains(where: { $0.id == artPiece.id }) {
            print("📝 Art piece not in collection yet, adding...")
            personalCollection.append(artPiece)
            Task {
                await syncAddToCollection(artPiece)
            }
        } else {
            print("⚠️ Art piece already in collection")
        }
    }
    
    func removeFromCollection(_ artPiece: ArtPiece) {
        personalCollection.removeAll { $0.id == artPiece.id }
        // Sync with Supabase in background
        Task {
            await syncRemoveFromCollection(artPiece)
        }
    }
    
    func toggleFavorite(_ artPiece: ArtPiece) {
        // First check if the piece is in the collection
        guard isInCollection(artPiece) else {
            print("⚠️ Cannot favorite - art piece must be in collection first")
            // TODO: Show UI feedback to user
            return
        }
        
        if favorites.contains(where: { $0.id == artPiece.id }) {
            favorites.removeAll { $0.id == artPiece.id }
            // Sync remove favorite
            Task {
                await syncRemoveFromFavorites(artPiece)
            }
        } else {
            favorites.append(artPiece)
            // Sync add favorite
            Task {
                await syncAddToFavorites(artPiece)
            }
        }
    }
    
    func isInCollection(_ artPiece: ArtPiece) -> Bool {
        personalCollection.contains(where: { $0.id == artPiece.id })
    }
    
    func isFavorite(_ artPiece: ArtPiece) -> Bool {
        favorites.contains(where: { $0.id == artPiece.id })
    }
    
    // Update the sync methods to handle Int to UUID conversion
    private func syncAddToCollection(_ artPiece: ArtPiece) async {
        guard let collectionId = personalCollectionId else {
            print("❌ No personal collection ID")
            return 
        }
        
        print("🔄 Syncing art piece \(artPiece.id) to collection \(collectionId)")
        do {
            try await supabase.addArtifactToCollection(artifactId: artPiece.id, collectionId: collectionId)
            print("✅ Successfully synced to collection")
        } catch {
            print("❌ Failed to sync: \(error)")
            await MainActor.run {
                personalCollection.removeAll { $0.id == artPiece.id }
            }
        }
    }
    
    private func syncRemoveFromCollection(_ artPiece: ArtPiece) async {
        guard let collectionId = personalCollectionId else { return }
        
        do {
            try await supabase.removeArtifactFromCollection(artifactId: artPiece.id, collectionId: collectionId)
        } catch {
            print("Failed to sync remove from collection: \(error)")
            await MainActor.run {
                personalCollection.append(artPiece)
            }
        }
    }
    
    private func syncAddToFavorites(_ artPiece: ArtPiece) async {
        guard let collectionId = personalCollectionId else { return }
        
        do {
            try await supabase.updateArtifactFavoriteStatus(
                artifactId: artPiece.id,
                collectionId: collectionId,
                isFavorite: true
            )
        } catch {
            print("❌ Failed to sync add to favorites: \(error)")
            await MainActor.run {
                favorites.removeAll { $0.id == artPiece.id }
            }
        }
    }
    
    private func syncRemoveFromFavorites(_ artPiece: ArtPiece) async {
        guard let collectionId = personalCollectionId else { return }
        
        do {
            try await supabase.updateArtifactFavoriteStatus(
                artifactId: artPiece.id,
                collectionId: collectionId,
                isFavorite: false
            )
        } catch {
            print("❌ Failed to sync remove from favorites: \(error)")
            await MainActor.run {
                favorites.append(artPiece)
            }
        }
    }
} 