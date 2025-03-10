import Foundation

struct Artifact: Identifiable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let description: String?
    let gallery: String?
    let collection: String?
    let collection_id: UUID?
    let image_url: String?
    let location: String?
    let on_display: Bool
    let featured: Bool
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case description
        case gallery
        case collection
        case collection_id
        case image_url
        case location
        case on_display = "on_display"
        case featured
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        gallery = try container.decodeIfPresent(String.self, forKey: .gallery)
        collection = try container.decodeIfPresent(String.self, forKey: .collection)
        collection_id = try container.decodeIfPresent(UUID.self, forKey: .collection_id)
        image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        on_display = try container.decode(Bool.self, forKey: .on_display)
        featured = try container.decode(Bool.self, forKey: .featured)
    }
} 
