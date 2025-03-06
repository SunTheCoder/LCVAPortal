import Foundation
import SwiftUI

struct DetailRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            Text(content)
                .font(.body)
                .foregroundColor(.white)
        }
    }
} 
