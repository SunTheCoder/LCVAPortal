import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(message.timestamp.dateValue(), style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
} 