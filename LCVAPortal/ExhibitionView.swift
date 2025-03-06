import SwiftUI

struct ExhibitionView: View {
    let exhibition: Exhibition
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AsyncImage(url: URL(string: exhibition.image_url ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.top, 130)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(exhibition.name)
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        // Dates Section
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(title: "Start Date", content: exhibition.start_date)
                            DetailRow(title: "Closing", content: exhibition.end_date)
                        }
                        .padding(.vertical)
                        
                        // Description
                        if let description = exhibition.description {
                            Text("About")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Links
                        VStack(alignment: .leading, spacing: 12) {
                            if let surveyUrl = exhibition.survey_url, 
                               let url = URL(string: surveyUrl) {
                                Link("Survey Link", destination: url)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            if let extraLink = exhibition.extra_link,
                               !extraLink.isEmpty,
                               let url = URL(string: extraLink) {
                                Link("Learn More", destination: url)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
