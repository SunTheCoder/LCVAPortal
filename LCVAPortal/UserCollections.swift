import Foundation

class UserCollections: ObservableObject {
    @Published var personalCollection: [ArtPiece] = []
    private let supabase = SupabaseClient.shared
    
    private var personalCollectionId: UUID?
    
    // Single method to handle both initialization and loading
    func loadUserCollections(userId: String) async {
        print("🔄 Loading collections for user: \(userId)")
        do {
            let collections = try await supabase.fetchUserCollections(userId: userId)
            print("📦 Fetched collections: \(collections)")
            
            if collections.isEmpty {
                print("⚠️ No collections found, creating new ones...")
                let personal = try await supabase.createUserCollection(userId: userId)
                self.personalCollectionId = personal
                
                await MainActor.run {
                    self.personalCollection = []
                }
            } else {
                if let personal = collections.first(where: { $0.name == "Personal" }) {
                    self.personalCollectionId = personal.id
                    let artifacts = try await supabase.fetchCollectionArtifacts(collectionId: personal.id)
                    await MainActor.run {
                        self.personalCollection = artifacts.map(convertToArtPiece)
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
            artist: artifact.artist ?? "",
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
    
    func isInCollection(_ artPiece: ArtPiece) -> Bool {
        personalCollection.contains(where: { $0.id == artPiece.id })
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
} 
