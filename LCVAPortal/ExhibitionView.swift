import SwiftUI

struct ExhibitionView: View {
    let exhibition: Exhibition
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image - full width
                    AsyncImage(url: URL(string: exhibition.image_url ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 360)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 360)
                    }
                    
                    // Content in fixed-width container
                    VStack(alignment: .leading) {
                        // Content container with fixed width
                        VStack(alignment: .leading, spacing: 16) {
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
                        .padding(24)
                        .frame(width: UIScreen.main.bounds.width - 32)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
