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
        VStack(alignment: .leading, spacing: 16) {
            // Display title
            Text(exhibition.name)
                .font(.system(size: 25))
                .bold()
                .padding(.vertical)
                .accessibilityAddTraits(.isHeader)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Reception, Closing, Description, and Links
            Text("Reception:")
                .font(.body)
                .bold()
                .accessibilityLabel(Text("Reception: \(exhibition.start_date)"))
            
            Text(exhibition.start_date)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(Text("Reception: \(exhibition.start_date)"))
            
            Text("Closing:")
                .font(.body)
                .bold()
                .accessibilityLabel(Text("Closing: \(exhibition.end_date)"))
            
            Text(exhibition.end_date)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(Text("Closing: \(exhibition.end_date)"))
            
            Text("About:")
                .font(.body)
                .bold()
                .accessibilityLabel(Text("About"))
            
            Text(exhibition.description ?? "")
                .font(.body)
                .accessibilityLabel(Text("Description: \(exhibition.description ?? "")"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            if let surveyUrl = exhibition.survey_url, let url = URL(string: surveyUrl) {
                Link("Survey Link", destination: url)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Open Survey Link")
            }
            
            if let extraLink = exhibition.extra_link, !extraLink.isEmpty, let url = URL(string: extraLink) {
                Text("Extra Content:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Link(extraLink, destination: url)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
