import SwiftUI

struct ExhibitionView: View {
    let exhibition: Exhibition
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Hero Image
                AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel(Text("Image of \(exhibition.title)"))
                } placeholder: {
                    ProgressView()
                        .accessibilityHidden(true)
                }
                .frame(maxHeight: 300)
                
                VStack {
                    Text(exhibition.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical)
                        .accessibilityAddTraits(.isHeader)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                
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
                    .foregroundColor(.blue)
                    .accessibilityLabel("Open Survey Link")
                
                Text(exhibition.description)
                    .font(.body)
                    .padding(.vertical)
                    .accessibilityLabel(Text("Description: \(exhibition.description)"))
                
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
            .padding()
            .navigationTitle(exhibition.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
} 