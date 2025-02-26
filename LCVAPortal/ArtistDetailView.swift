//
//  ArtistDetailView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/12/24.
//

import SwiftUI
import AVKit

struct ArtistDetailView: View {
    let artist: Artist
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Hero Image Section
                if let firstImage = artist.imageUrls.first {
                    Image(firstImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 300)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Artist Info
                    Text(artist.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text(artist.medium)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(artist.bio)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    // Videos Section
                    if !artist.videos.isEmpty {
                        Text("Videos")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        ForEach(artist.videos.prefix(3), id: \.self) { video in
                            VideoPlayerView(videoName: video)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    // Gallery Section
                    Text("Gallery")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    ForEach(artist.imageUrls, id: \.self) { imageUrl in
                        Image(imageUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
