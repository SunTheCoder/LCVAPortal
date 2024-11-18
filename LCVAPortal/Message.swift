//
//  ChatMessage.swift
//  LCVAPortal
//
//  Created by Sun English on 11/14/24.
//

import FirebaseCore

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Equatable  {
    @DocumentID var id: String?
    var text: String
    var timestamp: Timestamp
    var artPieceID: Int
    var username: String? // New property to store the username
    
    static func == (lhs: Message, rhs: Message) -> Bool {
            return lhs.id == rhs.id && lhs.text == rhs.text && lhs.timestamp == rhs.timestamp
        }
}
