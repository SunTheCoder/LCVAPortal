import SwiftUI

struct TranslatedLabelView: View {
    let translation: Translation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title and Language
                HStack {
                    Text(translation.title)
                        .font(.title)
                        .bold()
                    Spacer()
                    Text(translation.language)
                        .font(.subheadline)
                        .padding(6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción")
                        .font(.headline)
                    Text(translation.description)
                        .font(.body)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detalles")
                        .font(.headline)
                    
                    DetailRow(title: "Material", content: translation.material)
                    DetailRow(title: "Época", content: translation.era)
                    DetailRow(title: "Origen", content: translation.origin)
                }
                
                // Historical Context
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contexto Histórico")
                        .font(.headline)
                    Text(translation.lore)
                        .font(.body)
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .foregroundColor(.white)
        .navigationBarTitleDisplayMode(.inline)
    }
} 
