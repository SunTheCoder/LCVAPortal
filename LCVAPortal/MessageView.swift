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
                        Color.white.opacity(0.25) : 
                        Color.black.opacity(0.25))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)

                Text(dateFormatter.string(from: message.timestamp.dateValue()))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(isFromCurrentUser ? .trailing : .leading, 8)
            }

            if !isFromCurrentUser { Spacer() }
        }
        .padding(isFromCurrentUser ? .leading : .trailing, 50)
        .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)
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
