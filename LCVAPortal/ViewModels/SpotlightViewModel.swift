import Foundation

@MainActor
class SpotlightViewModel: ObservableObject {
    @Published var currentArtist: SpotlightArtist?
    @Published var spotlightMedia: [SpotlightMedia] = []
    @Published var isLoading = false
    
    private let supabase = SupabaseClient.shared
    
    func loadCurrentSpotlight() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Get the most recent artist
            let artists = try await supabase.fetchSpotlightArtists()
            
            if let artist = artists.first {
                currentArtist = artist
                
                // Get all media for this artist
                spotlightMedia = try await supabase.fetchSpotlightMedia(for: artist.id)
            }
        } catch {
            print("❌ Error loading spotlight:", error)
        }
    }
}

// MARK: - Supabase Client Extension
extension SupabaseClient {
    func fetchSpotlightArtists() async throws -> [SpotlightArtist] {
        let endpoint = "spotlight_artists?select=*&order=featured_date.desc&limit=1"
        let data = try await makeRequestWithResponse(
            endpoint: endpoint,
            method: "GET",
            cachePolicy: .useProtocolCachePolicy,
            cacheTime: 300 // Cache for 5 minutes
        )
        return try JSONDecoder().decode([SpotlightArtist].self, from: data)
    }
    
    func fetchSpotlightMedia(for artistId: UUID) async throws -> [SpotlightMedia] {
        let endpoint = "spotlight_media?select=*&spotlight_artist_id=eq.\(artistId)&order=media_order.asc"
        let data = try await makeRequestWithResponse(
            endpoint: endpoint,
            method: "GET",
            cachePolicy: .useProtocolCachePolicy,
            cacheTime: 300 // Cache for 5 minutes
        )
        return try JSONDecoder().decode([SpotlightMedia].self, from: data)
    }
} 
