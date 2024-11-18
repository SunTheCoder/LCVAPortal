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

    // Add more ArtPiece instances if needed for side-scrolling
]
