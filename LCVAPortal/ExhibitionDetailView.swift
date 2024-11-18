//
//  ExhibitionDetailView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/11/24.
//

import SwiftUI
import MapKit


struct ExhibitionDetailView: View {
    let exhibition: Exhibition
    
    
    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel(Text("Image of \(exhibition.title)"))
                } placeholder: {
                    ProgressView()
                        .accessibilityHidden(true) // Hide loading indicator from VoiceOver
                }
                .frame(maxHeight: 300)
                
                VStack {
                    Text(exhibition.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .accessibilityAddTraits(.isHeader)
                        .multilineTextAlignment(.center) // Center-align text content within the Text view
                        .frame(maxWidth: .infinity, alignment: .center) // Center horizontally within VStack
                    // Other views
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center VStack within parent view
                Text("Reception:\n\(exhibition.reception)")
                    .font(.body)
                    .padding(.vertical)
                    .accessibilityLabel(Text("Reception: \(exhibition.reception)"))
                Text("Closing:\n\(exhibition.closing)")
                    .font(.body)
                    .padding(.vertical)
                    .accessibilityLabel(Text("Closing: \(exhibition.closing)"))
                
                Link("Survey Link", destination: URL(string: exhibition.surveyUrl)!)
                    .font(.subheadline)
                    .foregroundColor(.blue)  // Style the link color
                                 // Optional: Underline for link appearance
                    .accessibilityLabel("Open Survey Link")
                Text(exhibition.description)
                    .font(.body)
                    .padding(.vertical)
                    .accessibilityLabel(Text("Description: \(exhibition.description)"))
//                Text("Survey:")
//                    .font(.caption)
//                    .padding(.bottom, 2)

               

                
                Text("Extra Content:")
                    .font(.headline)
                    .accessibilityLabel("Interactive Comic Making Game")
                
                if let extraLink = exhibition.extraLink, !extraLink.isEmpty, let url = URL(string: extraLink) {
                    Link(extraLink, destination: url)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .underline()
                        .accessibilityLabel(Text("Visit \(extraLink)"))
                        
                } else {
                    Text("No additional link available")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                    
                
            }
            .navigationTitle(exhibition.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .frame(maxWidth: 400, maxHeight: .infinity)
    
    }
}
