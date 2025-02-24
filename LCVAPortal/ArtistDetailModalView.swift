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
            ZStack {
                // Add background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        Text(artist.name)
                            .font(.system(size: 28))
                            .bold()
                            .foregroundColor(.white)  // Made white
                            .padding(.top)
                        
                        Text(artist.bio)
                            .font(.body)
                            .foregroundColor(.white)  // Made white
                            .padding(.bottom)
                        
                        Text("Video")
                            .font(.system(size: 20, weight: .regular, design: .serif))
                            .italic()
                            .foregroundColor(.white.opacity(0.7))  // Made white with opacity
                        
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
                            .foregroundColor(.white.opacity(0.7))  // Made white with opacity
                        
                        ForEach(artist.imageUrls, id: \.self) { imageUrl in
                            Image(imageUrl)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 400, maxHeight: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                .padding(.vertical, 10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Artist Spotlight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.lcvaBlue, for: .navigationBar)  // Added blue nav background
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)  // Force white text
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.white)  // Made white
                }
            }
        }
    }
}
