import SwiftUI

struct ExhibitionView: View {
    let exhibition: Exhibition
    
    var body: some View {
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
                
                if let surveyUrl = exhibition.survey_url, let url = URL(string: surveyUrl) {
                    Link("Survey Link", destination: url)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Open Survey Link")
                }
                
                Text(exhibition.description ?? "")
                    .font(.body)
                    .padding(.vertical)
                    .accessibilityLabel(Text("Description: \(exhibition.description ?? "")"))
                
                if let extraLink = exhibition.extra_link, !extraLink.isEmpty, let url = URL(string: extraLink) {
                    Link(extraLink, destination: url)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 