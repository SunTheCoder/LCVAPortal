import Foundation
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let db = Firestore.firestore()
    
    func loadMessages(for artifactId: UUID) async {
        let messagesRef = db.collection("chats")
            .document(artifactId.uuidString)
            .collection("messages")
            .order(by: "timestamp", descending: false)
        
        messagesRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self?.messages = documents.compactMap { document -> Message? in
                try? document.data(as: Message.self)
            }
        }
    }
    
    func sendMessage(artifactId: UUID, userId: String, username: String, content: String) async {
        let messageData: [String: Any] = [
            "id": UUID().uuidString,
            "userId": userId,
            "username": username,
            "text": content,
            "timestamp": Timestamp(),
            "artPieceID": artifactId.uuidString
        ]
        
        do {
            try await db.collection("chats")
                .document(artifactId.uuidString)
                .collection("messages")
                .addDocument(data: messageData)
        } catch {
            print("❌ Error sending message: \(error)")
        }
    }
} 