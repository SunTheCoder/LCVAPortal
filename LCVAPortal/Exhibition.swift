//
//  Exhibition.swift
//  LCVAPortal
//
//  Created by Sun English on 11/11/24.
//

import Foundation

struct Exhibition: Identifiable, Codable {
    let id: UUID
    let name: String
    let start_date: String  // Changed to String to match DB
    let end_date: String    // Changed to String to match DB
    let description: String?
    let current: Bool
    let past: Bool
    let gallery_name: String?
    let survey_url: String?
    let image_url: String?
    let extra_link: String?
    let video_preview: String?
    var artist: [String] = []
    
    // Computed properties to maintain compatibility with existing views
    var title: String { name }
    var imageUrl: String { image_url ?? "" }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case start_date
        case end_date
        case description
        case current
        case past
        case gallery_name
        case survey_url
        case image_url
        case extra_link
        case video_preview
    }
}

// Add this struct to match exhibition_artists table
struct ExhibitionArtist: Codable {
    let id: UUID
    let exhibition_id: UUID
    let artist_name: String
}

// Define current exhibitions first
let currentExhibitions = [
    Exhibition(
        id: UUID(),
        name: "Choose Your Own Adventure",
        start_date: "2025-02-01",
        end_date: "2025-02-28",
        description: "Digital Horizons explores the intersection of traditional art and digital technology. This groundbreaking exhibition features interactive installations, virtual reality experiences, and digital paintings that challenge our perception of modern art. Visitors are invited to engage with artworks that respond to their presence, creating a unique and immersive experience.",
        current: true,
        past: false,
        gallery_name: "Main Gallery",
        survey_url: "https://lcva.longwood.edu/exhibitions/digital-horizons",
        image_url: "https://lcva.longwood.edu/wp-content/uploads/2025/02/Bagley-Fruit-Stand.jpg",
        extra_link: "",
        video_preview: nil,
        artist: ["Selections from the Collection"]
    ),
    
    Exhibition(
        id: UUID(),
        name: "Bad Kitty Does Not Like Art Museums",
        start_date: "2024-08-01",
        end_date: "2024-08-31",
        description: "Bad Kitty Does Not Like Art Museums highlights works of art from author and illustrator Nick Bruel. For over twenty years, his stories have connected with children and adults alike. His whimsical narratives teach valuable life lessons through humor and the curious Bad Kitty. \n\nThough she wasn't always a bad cat, she just didn't want to eat asparagus, horseradish, spinach, or zucchini. She wanted an assortment of anchovies, hippo hamburgers, rhino ravioli, or shark sushi. She may not have been as patient as she should have been, but that's okay. She is learning – she is just a little kitty. \n\nAnd Bad Kitty grows up, just like we do. She goes on vacation, takes a test, gets a bath, gets a phone, and even runs for president. These stories teach that when times get tough, we figure out ways to persevere and succeed, or how to handle disappointment. \n\nBad Kitty Does Not Like Art Museums is an invitation to find your own growth, revisit something you don't like, and have some laughs. The LCVA, in conjunction with the Virginia Children's Book Festival, asks that you don't claw the curtains, overturn litter boxes, or ruin any rugs. \n\nThis exhibition is the eight iteration of the LCVA's annual Arts and Letters exhibition series showcasing the best in the art of children's literature, which is proudly presented in conjunction with the Virginia Children's Book Festival.",
        current: true,
        past: false,
        gallery_name: "Gallery A",
        survey_url: "https://docs.google.com/forms/d/e/1FAIpQLScU3PsVCtCWAzyHbxIqa7yf-yK1A2OLYW0R500ZWyZbAp91CQ/viewform?usp=sf_link",
        image_url: "https://lcva.longwood.edu/wp-content/uploads/2024/08/Bady-Kitty-Starry-Night-1.jpg",
        extra_link: "https://badkittycomicgame.netlify.app",
        video_preview: nil,
        artist: ["Nick Bruel"]
    ),
]

// Then define sample/past exhibitions
let sampleExhibitions = [
    Exhibition(
        id: UUID(),
        name: "Letters from Farmville",
        start_date: "2024-09-06",
        end_date: "2025-01-21",
        description: "In 1989 Dr. Debra Jean Ambush came to Farmville to help settle an estate for a recently passed family member. In her familgit stashy's farm house was a trunk.  This trunk contained receipts, papers, photographs, and personal correspondence dating back to 1872. For over 30 years these documents, which are an ancestral connection to the artist, have served as vital sources of artistic inspiration and interpretation as she seeks to understand her family's histories, stories, and memories. Letters from Farmville: Reflections on Ancestral Arrival into Descendant Memory is a four-part exhibition that visualizes African American family history to illuminate the ways in which memory is constructed, lost, and cherished. \n\nThe Longwood Center for the Visual Arts (LCVA) welcomes the community to an opening reception on Friday, September 6 from 5:30 – 8 pm; early entry for Friends & Partners at 5 pm. The exhibition will be on view from September 6, 2024—January 21, 2025. Letters from Farmville is made possible in part through the generous sponsorship of Ilsa Loeser and Letterpress Communications.",
        current: false,
        past: true,
        gallery_name: "Gallery A",
        survey_url: "no link",
        image_url: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        extra_link: "https://youtu.be/MKdqit-fVkY?si=j32FwPuIqSGnwMio",
        video_preview: "Farmville_Looped",
        artist: ["Debra Jean Ambush"]
    ),
    Exhibition(
        id: UUID(),
        name: "Of Time, and The Town",
        start_date: "2024-09-06",
        end_date: "2025-01-21",
        description: "Of Time, and the Town from filmmaker David Ellsworth poetically depicts twenty years of changes and constants in the built environment of Farmville, Virginia and in the rural areas surrounding it. The film's super-8 film images bear witness to how everyday locales provide markers of the town's social evolution. A young couple labors to renovate an abandoned 19th century school and make it their home while the town's previously shuttered all-Black high school finds new life as a civil rights museum documenting the 1950s student strike that helped integrate the county's schools. Children grow as one-hundred-year-old oak trees fall. Excerpts from the town's AM radio station provide a sonic touchstone that complements the film's evocative sound design. \n\nThe Longwood Center for the Visual Arts (LCVA) welcomes the community to an opening reception on Friday, September 6 from 5:30 – 8 pm; early entry for Friends & Partners at 5 pm. This exhibition will be on view from September 6, 2024—January 21, 2025..",
        current: false,
        past: true,
        gallery_name: "Gallery A",
        survey_url: "no link",
        image_url: "https://lcva.longwood.edu/wp-content/uploads/2024/08/Screenshot-299.png",
        extra_link: nil,
        video_preview: nil,
        artist: ["David Ellsworth"]
    ),
]
