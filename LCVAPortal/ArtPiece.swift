//
//  ArtPiece.swift
//  LCVAPortal
//
//  Created by Sun English on 11/12/24.
//

import Foundation
import CoreLocation

struct ArtPiece: Identifiable, Decodable {
    let id: UUID
    let title: String
    let artist: String
    let description: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    let material: String
    let era: String
    let origin: String
    let lore: String
    
    // New accessibility and language materials
    var translations: [Translation]?
    var audioTour: AudioGuide?
    var brailleLabel: BrailleLabel?
    var adaAccessibility: ADAInfo?
}

// Supporting types for accessibility features
struct Translation: Identifiable, Decodable {
    let id = UUID()
    let language: String
    let title: String
    let description: String
    let material: String
    let era: String
    let origin: String
    let lore: String
}

struct AudioGuide: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let audioUrl: String  // URL to hosted audio file
    let duration: TimeInterval
    let language: String
}

struct BrailleLabel: Identifiable, Decodable {
    let id = UUID()
    let documentUrl: String  // URL to printable braille document
    let status: BrailleStatus
    
    enum BrailleStatus: String, Decodable {
        case available
        case requestable
        case inProgress
    }
}

struct ADAInfo: Identifiable, Decodable {
    let id = UUID()
    let isWheelchairAccessible: Bool
    let hasAudioDescription: Bool
    let hasTactileElements: Bool
    let additionalNotes: String?
}


