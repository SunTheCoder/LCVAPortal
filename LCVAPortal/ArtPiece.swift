//
//  ArtPiece.swift
//  LCVAPortal
//
//  Created by Sun English on 11/12/24.
//

import Foundation
import CoreLocation

struct ArtPiece: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    let material: String
    let era: String
    let origin: String
    let lore: String

 

}


let featuredArtPieces = [
    ArtPiece(
        id: 1,
        title: "Stoned Joanie",
        description: "A beautiful sculpture located in the central plaza. Stop touching her!!!",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297349489535044, 
        longitude: -78.39673270726009,
        
        material: "Steel",
        era: "19th Century",
        origin: "United States",
        lore: "This sculpture was commissioned by the Longwood College Foundation in 19 to commemorate the 100th anniversary of the college."
    ),
    ArtPiece(
        id: 2,
        title: "Echoes of the Past",
        description: "A hauntingly beautiful painting depicting an ancient, fog-covered forest with ghostly silhouettes of forgotten travelers. The scene is illuminated by a pale moonlight, casting eerie shadows that dance among the twisted trees.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.296903755719605,
        longitude: -78.3957061249452,
        
        material: "Oil on Canvas",
        era: "Contemporary",
        origin: "Unknown",
        lore: "This mysterious painting is said to have appeared in a small gallery one night without explanation. Legend has it that anyone who stares at it too long can hear whispers of the past echoing through the forest, drawing them closer to the secrets it hides."
    ),

    ArtPiece(
        id: 3,
        title: "Celestial Bloom",
        description: "An intricate sculpture crafted from rare crystals and metals, depicting a flower in full bloom, with petals that appear to be made of stardust. The piece shimmers under any light, casting small, colorful reflections that dance across the room.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297766429606675,
        longitude: -78.3956198929651,
        
        material: "Crystals, Meteoric Iron, Gold Leaf",
        era: "21st Century",
        origin: "Astoria Observatory Art Collective",
        lore: "This sculpture is rumored to be created from fragments of a fallen meteor, symbolizing the eternal beauty of the universe. It's believed to bring inspiration to anyone who gazes upon it, with the colors of the petals shifting slightly with the viewer's mood."
    ),

    ArtPiece(
        id: 4,
        title: "The Rotunda Guardian",
        description: "A towering bronze sculpture of an abstract figure that seems to shift forms depending on the viewing angle. Located at the entrance of the Rotunda.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.298123,
        longitude: -78.395821,
        material: "Bronze, Copper Patina",
        era: "Contemporary",
        origin: "Virginia",
        lore: "Commissioned for Longwood's bicentennial, this piece represents the spirit of education and transformation."
    ),
    
    ArtPiece(
        id: 5,
        title: "Wisdom's Window",
        description: "A stunning stained glass installation depicting scenes from literature and science, filtering sunlight into rainbow patterns across the floor.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.296789,
        longitude: -78.394567,
        material: "Stained Glass, Lead Framework",
        era: "2020",
        origin: "Richmond Glass Works",
        lore: "Each panel represents a different academic discipline, creating a visual symphony of knowledge."
    ),
    
    ArtPiece(
        id: 6,
        title: "Digital Dreams",
        description: "An interactive LED sculpture that responds to movement, creating patterns of light that mirror the viewer's gestures.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297234,
        longitude: -78.395912,
        material: "LED Arrays, Motion Sensors, Aluminum",
        era: "2023",
        origin: "Tech Arts Collective",
        lore: "The first fully interactive art installation on campus, representing the fusion of technology and creativity."
    ),
    
    ArtPiece(
        id: 7,
        title: "Heritage Oak",
        description: "A massive ceramic mural depicting the growth rings of Longwood's oldest oak tree, with historical events marked in metallic glazes.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297890,
        longitude: -78.396023,
        material: "Ceramic, Metallic Glazes",
        era: "2019",
        origin: "Local Artisan Collective",
        lore: "Each ring represents a year in Longwood's history, with significant events marked in gold."
    ),
    
    ArtPiece(
        id: 8,
        title: "Quantum Garden",
        description: "A kinetic sculpture garden with metal flowers that move with the wind, creating ever-changing patterns and soft musical tones.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.298345,
        longitude: -78.395234,
        material: "Stainless Steel, Brass, Wind Chimes",
        era: "2022",
        origin: "International Sculpture Symposium",
        lore: "Inspired by quantum mechanics, each flower represents a different atomic particle."
    ),
    
    ArtPiece(
        id: 9,
        title: "Time Capsule Mosaic",
        description: "A sprawling mosaic made from historical photographs and documents transferred onto ceramic tiles, creating a visual timeline of campus life.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.296567,
        longitude: -78.395678,
        material: "Ceramic Tiles, Photo Transfer",
        era: "2021",
        origin: "Alumni Art Project",
        lore: "Contains hidden QR codes that link to oral histories and archived footage."
    ),
    
    ArtPiece(
        id: 10,
        title: "The Scholar's Path",
        description: "A series of carved stone benches forming a meditation path, each featuring quotes from different philosophical traditions.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297123,
        longitude: -78.394890,
        material: "Granite, Bronze Inlay",
        era: "2018",
        origin: "International Stone Carving Symposium",
        lore: "Students often rub specific quotes for good luck before exams."
    ),
    
    ArtPiece(
        id: 11,
        title: "Echo Chamber",
        description: "A sound sculpture installation that creates harmonic resonances based on the number of people present in the space.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297456,
        longitude: -78.395345,
        material: "Acoustic Panels, Digital Sound System",
        era: "2024",
        origin: "Sound Art Institute",
        lore: "The harmonies change with the seasons and time of day."
    ),
    
    ArtPiece(
        id: 12,
        title: "Fibonacci's Dance",
        description: "A series of suspended metal spirals that cast mathematical shadows, aligned with the golden ratio.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.298012,
        longitude: -78.395789,
        material: "Polished Aluminum, Steel Cable",
        era: "2020",
        origin: "Mathematics Department Commission",
        lore: "The shadows align perfectly only during the equinoxes."
    ),
    
    ArtPiece(
        id: 13,
        title: "Memory Wall",
        description: "An interactive wall where visitors can project their own memories and stories, creating a constantly evolving digital tapestry.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297234,
        longitude: -78.394567,
        material: "Digital Projection, Interactive Interface",
        era: "2023",
        origin: "Digital Arts Department",
        lore: "Contains over 10,000 contributed memories from the Longwood community."
    ),
    
    ArtPiece(
        id: 14,
        title: "The Librarian's Dream",
        description: "A suspended installation of illuminated books that seem to float in mid-air, their pages gently turning in the breeze.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.296890,
        longitude: -78.395912,
        material: "Paper, LED Lighting, Monofilament",
        era: "2022",
        origin: "Book Arts Collective",
        lore: "Each book contains actual poetry written by Longwood students over the past century."
    ),
    
    ArtPiece(
        id: 15,
        title: "Periodic Table Garden",
        description: "A garden where each plant species corresponds to a different element on the periodic table, with metallic markers explaining the connections.",
        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/451624173_1005858958207827_1691580555828386781_n.jpg",
        latitude: 37.297789,
        longitude: -78.396123,
        material: "Living Plants, Metal Markers",
        era: "2021",
        origin: "Chemistry-Botany Collaboration",
        lore: "The garden changes colors throughout the seasons, creating a living representation of chemical reactions."
    )
]
