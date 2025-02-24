import SwiftUI

struct HoursAccordionView: View {
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    HourRow(day: "Monday", hours: "Closed")
                    HourRow(day: "Tuesday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Wednesday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Thursday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Friday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Saturday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Sunday", hours: "1:00 PM - 5:00 PM")
                }
                .padding(.vertical, 8)
                .foregroundColor(.white)
            },
            label: {
                Text("Regular Hours")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(.white)
            }
        )
        .accentColor(.white)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue.opacity(0.7), Color.white.opacity(0.1)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(7)
            .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

struct HourRow: View {
    let day: String
    let hours: String
    
    var body: some View {
        HStack {
            Text(day)
                .frame(width: 120, alignment: .leading)
                .font(.subheadline)
                .foregroundColor(.white)
            Text(hours)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HoursAccordionView()
} 