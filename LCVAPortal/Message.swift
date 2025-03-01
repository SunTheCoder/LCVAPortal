//
//  ChatMessage.swift
//  LCVAPortal
//
//  Created by Sun English on 11/14/24.
//

import FirebaseCore

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let username: String  // Keep username for display
    let userId: String    // Store Firebase user ID
    let text: String
    let timestamp: Timestamp
    let artPieceID: String  // Store as string since we're using UUID strings in Firestore
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case userId
        case text
        case timestamp
        case artPieceID
    }
    
    // Add Equatable conformance
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.username == rhs.username &&
               lhs.userId == rhs.userId &&
               lhs.text == rhs.text &&
               lhs.timestamp == rhs.timestamp &&
               lhs.artPieceID == rhs.artPieceID
    }
}
