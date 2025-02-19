import SwiftUI

struct InfoAccordionView: View {
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    InfoSection(
                        title: "How It Works",
                        content: "Our AI tool analyzes your mood input to suggest artworks that resonate with your current emotional state. It considers factors like color theory, artistic style, and thematic elements to create personalized recommendations."
                    )
                    
                    InfoSection(
                        title: "Data Privacy",
                        content: "Your mood inputs are processed anonymously and are not stored. We use this information solely to enhance your immediate art discovery experience."
                    )
                    
                    InfoSection(
                        title: "Recommendations",
                        content: "Suggestions are drawn from our permanent collection and current exhibitions, helping you discover pieces that might particularly speak to you today."
                    )
                }
                .padding(.top, 4)
            },
            label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("About the Art Recommendation Tool")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.03))
        )
        .padding(.horizontal)
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .bold()
            Text(content)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
} 