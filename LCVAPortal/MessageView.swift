import SwiftUI
import FirebaseFirestore

struct MessageView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let dateFormatter: DateFormatter
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.username ?? "Anonymous")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Text(message.text)
                    .padding(8)
                    .background(isFromCurrentUser ? 
                        Color.blue.opacity(0.3) : 
                        Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)

                Text(dateFormatter.string(from: message.timestamp.dateValue()))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

extension DateFormatter {
    static func shortDateTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
