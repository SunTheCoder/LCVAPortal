import SwiftUI
import FirebaseFirestore

struct ChatView: View {
    let artPieceID: Int
    @StateObject var userManager: UserManager

    @State private var newMessage = ""
    @State private var messages = [Message]()
    private let db = Firestore.firestore()
    private let dateFormatter = DateFormatter.shortDateTimeFormatter()

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageView(
                                message: message,
                                isFromCurrentUser: message.username == userManager.currentUser?.displayName,
                                dateFormatter: dateFormatter,
                                deleteAction: {
                                    if let messageID = message.id {
                                        deleteMessage(messageID: messageID)
                                    }
                                }
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _, _ in
                    scrollToBottom(proxy: scrollViewProxy)
                }

                HStack {
                    TextField("Enter message...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button(action: {
                        sendMessage()
                        if let lastMessageID = messages.last?.id {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                        }
                    }) {
                        Text("Send")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(4)
                            .padding(.horizontal, 2)
                            
                            .background(Color.primary.opacity(0.2))
                            
                            .cornerRadius(7)
                            .shadow(radius: 2)
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
        }
        .onAppear(perform: loadMessages)
    }

    func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    func sendMessage() {
        guard let currentUser = userManager.currentUser else { return }
        let username = currentUser.displayName ?? "Anonymous"
        let filteredMessage = filterMessage(newMessage)

        let messageData: [String: Any] = [
            "text": filteredMessage,
            "timestamp": Timestamp(),
            "artPieceID": artPieceID,
            "username": username
        ]

        db.collection("chats")
            .document("\(artPieceID)")
            .collection("messages")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    newMessage = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
    }

    func loadMessages() {
        db.collection("chats")
            .document("\(artPieceID)")
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading messages: \(error.localizedDescription)")
                    return
                }
                self.messages = snapshot?.documents.compactMap { document in
                    try? document.data(as: Message.self)
                } ?? []
            }
    }

    func filterMessage(_ message: String) -> String {
        let bannedWords = ["nigga", "fuck", "shit", "bitch", "dumbass"]
        var filteredMessage = message
        for word in bannedWords {
            filteredMessage = filteredMessage.replacingOccurrences(of: word, with: "****")
        }
        return filteredMessage
    }

    func deleteMessage(messageID: String) {
        db.collection("chats")
            .document("\(artPieceID)")
            .collection("messages")
            .document(messageID)
            .delete { error in
                if let error = error {
                    print("Error deleting message: \(error.localizedDescription)")
                }
            }
    }
}
