import SwiftUI
import FirebaseFirestore

// Break out the send button
struct SendButton: View {
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Send")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(4)
                .padding(.horizontal, 2)
                .background(Color.primary.opacity(0.2))
                .cornerRadius(7)
                .shadow(radius: 2)
        }
        .disabled(isDisabled)
    }
}

// Simplified MessageInputView
struct MessageInputView: View {
    @Binding var newMessage: String
    let onSend: () -> Void
    
    private var isMessageEmpty: Bool {
        newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack {
            TextField("Enter message...", text: $newMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SendButton(
                isDisabled: isMessageEmpty,
                action: onSend
            )
        }
        .padding()
    }
}

// Break out the art piece header
struct ArtPieceHeaderView: View {
    let artPiece: ArtPiece
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            Text(artPiece.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
    }
}

// Main ChatView
struct ChatView: View {
    let artPieceID: UUID
    @StateObject var userManager: UserManager
    @State private var newMessage = ""
    @State private var messages = [Message]()
    @State private var artPiece: ArtPiece?
    
    private let db = Firestore.firestore()
    private let supabase = SupabaseClient.shared
    private let dateFormatter = DateFormatter.shortDateTimeFormatter()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if let artPiece = artPiece {
                    ArtPieceHeaderView(artPiece: artPiece)
                }
                
                MessagesView(
                    messages: messages,
                    userManager: userManager,
                    dateFormatter: dateFormatter,
                    onDelete: deleteMessage
                )
                
                MessageInputView(newMessage: $newMessage, onSend: sendMessage)
            }
        }
        .task {
            await loadArtPiece()
            loadMessages()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            ),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // Move the messages view to its own component
    private func loadArtPiece() async {
        do {
            let artifacts = try await supabase.fetchArtifacts()
            if let artifact = artifacts.first(where: { $0.id == artPieceID }) {
                self.artPiece = ArtPiece(
                    id: artifact.id,
                    title: artifact.title,
                    description: artifact.description ?? "",
                    imageUrl: artifact.image_url ?? "",
                    latitude: 0.0,
                    longitude: 0.0,
                    material: artifact.gallery ?? "Unknown",
                    era: "",
                    origin: "",
                    lore: "",
                    translations: nil,
                    audioTour: nil,
                    brailleLabel: nil,
                    adaAccessibility: nil
                )
            }
        } catch {
            print("❌ Failed to fetch art piece: \(error)")
        }
    }
    
    // Keep existing methods
    private func loadMessages() {
        // Update the collection path to use UUID string
        let messagesRef = db.collection("chats")
            .document(artPieceID.uuidString)
            .collection("messages")
            .order(by: "timestamp", descending: false)
        
        messagesRef.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            messages = documents.compactMap { document -> Message? in
                try? document.data(as: Message.self)
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let userId = userManager.currentUser?.uid else {
            return
        }
        
        // Get username, defaulting to "Anonymous" if not available
        let username = userManager.currentUser?.displayName ?? "Anonymous"
        
        let messageData: [String: Any] = [
            "id": UUID().uuidString,
            "username": username,
            "userId": userId,
            "text": newMessage,
            "timestamp": Timestamp(),
            "artPieceID": artPieceID.uuidString
        ]
        
        // Update to use UUID string in the path
        let chatRef = db.collection("chats")
            .document(artPieceID.uuidString)
            .collection("messages")
        
        chatRef.addDocument(data: messageData) { error in
            if let error = error {
                print("❌ Error sending message: \(error)")
            } else {
                newMessage = ""
            }
        }
    }
    
    private func deleteMessage(messageID: String) {
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

// Messages view component
struct MessagesView: View {
    let messages: [Message]
    let userManager: UserManager
    let dateFormatter: DateFormatter
    let onDelete: (String) -> Void
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                if messages.isEmpty {
                    EmptyMessagesView()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageView(
                            message: message,
                            isFromCurrentUser: message.userId == userManager.currentUser?.uid,
                            dateFormatter: dateFormatter,
                            deleteAction: {
                                if let messageID = message.id {
                                    onDelete(messageID)
                                }
                            }
                        )
                        .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: messages) { _, _ in
                if let lastId = messages.last?.id {
                    scrollViewProxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }
}

// Empty state view
struct EmptyMessagesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 4)
            
            Text("Start a conversation about this art piece!")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Share your thoughts, ask questions, or discuss what this piece means to you.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
