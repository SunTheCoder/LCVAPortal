import Foundation

struct Collection: Identifiable, Codable {
    let id: UUID
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
} 