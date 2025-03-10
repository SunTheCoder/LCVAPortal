import Foundation

struct ArtifactReflection: Identifiable, Codable, Equatable {
    let id: UUID
    let artifactId: UUID
    let userId: String
    let reflectionType: String  // Could be "text", "audio", "video" etc.
    let textContent: String
    let mediaUrl: String?
    let createdAt: String  // This is the ISO timestamp from Supabase
    fileprivate let user: User?  // Make property fileprivate to match User struct
    
    enum CodingKeys: String, CodingKey {
        case id
        case artifactId = "artifact_id"
        case userId = "user_id"
        case reflectionType = "reflection_type"
        case textContent = "text_content"
        case mediaUrl = "media_url"
        case createdAt = "created_at"
        case user = "users"  // Match the join query
    }
    
    // Helper to get username
    var username: String {
        user?.name ?? "Anonymous"
    }
    
    // Add Equatable conformance
    static func == (lhs: ArtifactReflection, rhs: ArtifactReflection) -> Bool {
        lhs.id == rhs.id &&
        lhs.artifactId == rhs.artifactId &&
        lhs.userId == rhs.userId &&
        lhs.reflectionType == rhs.reflectionType &&
        lhs.textContent == rhs.textContent &&
        lhs.mediaUrl == rhs.mediaUrl &&
        lhs.createdAt == rhs.createdAt &&
        lhs.user?.name == rhs.user?.name
    }
}

// Add User struct for decoding
fileprivate struct User: Codable {
    let name: String
} 