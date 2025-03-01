import Foundation

struct UserCollectionArtifact: Codable, Identifiable {
    let id: UUID
    let collection_id: UUID
    let artifact_id: UUID
    let is_favorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case collection_id
        case artifact_id
        case is_favorite
    }
} 
