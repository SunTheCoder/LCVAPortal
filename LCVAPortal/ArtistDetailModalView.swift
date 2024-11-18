//
//  ArtistDetailModalView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/15/24.
//

import SwiftUI
import AVKit

struct ArtistDetailModalView: View {
    let artist: Artist
    @Binding var isPresented: Bool // Binding to control modal visibility
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text(artist.name)
                        .font(.system(size: 28))
                        .bold()
                        .padding(.top)
                    
                    Text(artist.bio)
                        .font(.body)
                        .padding(.bottom)
                    
                    
                    
                    Text("Video")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.secondary)
                    
                    ForEach(artist.videos.prefix(3), id: \.self) { video in
                        VideoPlayerView(videoName: video)
                            .scaledToFill()
                            .frame(maxWidth: 400, maxHeight: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                            .padding(.vertical, 10)
                    }
                    
                    Text("Mixed Media")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(.secondary)
                    
                    ForEach(artist.imageUrls, id: \.self) { imageUrl in
                        Image(imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 400, maxHeight: 400)  // Set the size as desired
                            .clipShape(RoundedRectangle(cornerRadius: 7))  // Optional: Rounded corners
                            .padding(.vertical, 10)  // Vertical padding to center the images in the ScrollView
                    }
                }
                .padding()
            }
            .navigationTitle("Local Artist Spotlight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
