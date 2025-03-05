import Foundation

struct SpotlightMedia: Identifiable, Codable {
    let id: UUID
    let spotlight_artist_id: UUID
    let media_url: String
    let media_type: String // "image" or "video"
    let media_order: Int
    private let created_at_string: String
    let title: String?
    let description: String?
    let medium: String?
    
    var created_at: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: created_at_string)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case spotlight_artist_id
        case media_url
        case media_type
        case media_order
        case created_at_string = "created_at"
        case title
        case description
        case medium
    }
} 