import Foundation

// Main exhibition data structure
struct ExhibitionData: Codable, Identifiable {
    var id: UUID { exhibitions.id }
    let exhibitions: Exhibition
    let exhibition_artifacts: ExhibitionArtifactJoin?
    let exhibition_artists: ExhibitionArtistJoin?
    
    // Add CodingKeys to match the RPC response
    enum CodingKeys: String, CodingKey {
        case exhibitions
        case exhibition_artifacts
        case exhibition_artists
    }
}

// Join table between exhibitions and artifacts
struct ExhibitionArtifactJoin: Codable, Identifiable {
    let id: UUID
    let exhibition_id: UUID
    let artifact_id: UUID
}

// Join table between exhibitions and artists - using the existing ExhibitionArtist model
typealias ExhibitionArtistJoin = ExhibitionArtist

// Remove DateFormatter since we're using String for dates 
