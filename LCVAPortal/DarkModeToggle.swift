import SwiftUI

struct DarkModeToggle: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) var systemColorScheme
    
    var body: some View {
        Toggle(isOn: $isDarkMode) {
            HStack {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                Text(isDarkMode ? "Dark Mode" : "Light Mode")
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    DarkModeToggle()
} 