import Foundation

struct ArtifactReflection: Identifiable, Codable, Equatable {
    let id: UUID
    let artifactId: UUID
    let userId: String
    let reflectionType: String  // Could be "text", "audio", "video" etc.
    let textContent: String
    let mediaUrl: String?
    let createdAt: String  // Change to String since Supabase returns ISO timestamp
    
    enum CodingKeys: String, CodingKey {
        case id
        case artifactId = "artifact_id"
        case userId = "user_id"
        case reflectionType = "reflection_type"
        case textContent = "text_content"
        case mediaUrl = "media_url"
        case createdAt = "created_at"
    }
} 