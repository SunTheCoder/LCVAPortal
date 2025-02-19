import SwiftUI

struct HoursAccordionView: View {
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    HourRow(day: "Monday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Tuesday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Wednesday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Thursday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Friday", hours: "11:00 AM - 5:00 PM")
                    HourRow(day: "Saturday - Sunday", hours: "Closed")
                }
                .padding(.vertical, 8)
            },
            label: {
                Text("Regular Hours")
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(.secondary)
            }
        )
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
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
            Text(hours)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HoursAccordionView()
} 