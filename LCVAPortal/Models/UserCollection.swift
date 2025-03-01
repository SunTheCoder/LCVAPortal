import Foundation

struct UserCollection: Codable, Identifiable {
    let id: UUID
    let user_id: String
    let name: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case name
        case description
    }
}
