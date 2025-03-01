import Foundation

// Helper extension for date formatting
extension ISO8601DateFormatter {
    static let supabase: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

// For Supabase users table
struct SupabaseUser: Codable {
    let id: String      // UUID from Firebase auth
    let email: String
    let name: String?
    let created_at: String?  // ISO8601 string from Supabase
    let avatar_url: String?
    
    init(id: String, email: String, name: String?, created_at: Date?, avatar_url: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.created_at = created_at.map { ISO8601DateFormatter.supabase.string(from: $0) }
        self.avatar_url = avatar_url
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, created_at, avatar_url
    }
}

// For empty responses
struct EmptyResponse: Codable {} 