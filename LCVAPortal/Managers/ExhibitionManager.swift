import SwiftUI
import Combine

@MainActor
class ExhibitionManager: ObservableObject {
    static let shared = ExhibitionManager()
    private let supabase = SupabaseClient.shared
    
    @Published var exhibitionData: [ExhibitionData] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private init() {}
    
    func preloadExhibitionData() async {
        guard exhibitionData.isEmpty else { return }
        
        print("🎨 Loading exhibition data...")
        isLoading = true
        
        do {
            let data = try await supabase.makeRequestWithResponse(
                endpoint: "rpc/get_exhibition_data",
                method: "GET"
            )
            
            let decodedData = try JSONDecoder().decode([ExhibitionData].self, from: data)
            self.exhibitionData = decodedData
            
            print("✅ Exhibition data loaded: \(decodedData.count) items")
            isLoading = false
            
        } catch {
            print("❌ Error loading exhibition data: \(error)")
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    // Helper methods to filter data
    var currentExhibitions: [Exhibition] {
        exhibitionData.map(\.exhibitions).filter { $0.current }
    }
    
    var pastExhibitions: [Exhibition] {
        exhibitionData.map(\.exhibitions).filter { $0.past }
    }
    
    func getArtistsForExhibition(_ exhibitionId: UUID) -> ExhibitionArtistJoin? {
        exhibitionData
            .first { $0.exhibitions.id == exhibitionId }?
            .exhibition_artists
    }
    
    func getArtifactsForExhibition(_ exhibitionId: UUID) -> ExhibitionArtifactJoin? {
        exhibitionData
            .first { $0.exhibitions.id == exhibitionId }?
            .exhibition_artifacts
    }
    
    // Helper to get artifact ID for an exhibition
    func getArtifactIdForExhibition(_ exhibitionId: UUID) -> UUID? {
        getArtifactsForExhibition(exhibitionId)?.artifact_id
    }
} 