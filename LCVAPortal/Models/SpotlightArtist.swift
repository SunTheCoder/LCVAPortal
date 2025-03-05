import Foundation

struct SpotlightArtist: Identifiable, Codable {
    let id: UUID
    let artist_name: String
    let bio: String?
    let art_title: String?
    let art_description: String?
    let featured_date: String  // Keep as string since it's TEXT in Supabase
    let extra_link: String?
    let artist_photo_url: String?
    let hero_image_url: String?
} 