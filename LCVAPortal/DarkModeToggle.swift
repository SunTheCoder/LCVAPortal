import SwiftUI

struct DarkModeToggle: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .foregroundColor(.white)
            Text("Light Mode")
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isDarkMode)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    DarkModeToggle()
} 