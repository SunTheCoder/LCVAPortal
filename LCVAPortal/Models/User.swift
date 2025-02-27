import Foundation

// For Supabase users table
struct SupabaseUser: Codable {
    let id: String      // UUID from Firebase auth
    let email: String
    let name: String?
    let created_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case created_at
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(name, forKey: .name)
        
        // Format the date as ISO8601
        if let date = created_at {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = formatter.string(from: date)
            try container.encode(dateString, forKey: .created_at)
        }
    }
}

// For empty responses
struct EmptyResponse: Codable {} 