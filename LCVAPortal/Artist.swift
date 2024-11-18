//
//  Artist.swift
//  LCVAPortal
//
//  Created by Sun English on 11/12/24.
//
import Foundation

struct Artist: Identifiable {
    let id = UUID()
    let name: String
    let bio: String
    let imageUrls: [String] // URLs of the artist's artwork images
    let videos: [String]
}

