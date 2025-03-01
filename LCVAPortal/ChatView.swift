import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import AVKit

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

// Add this before the ChatView struct
enum ChatContent: Identifiable, Equatable {
    case message(Message)
    case reflection(ArtifactReflection)
    
    var id: String {
        switch self {
        case .message(let message): 
            return message.id ?? UUID().uuidString
        case .reflection(let reflection): 
            return reflection.id.uuidString
        }
    }
    
    var date: Date {
        switch self {
        case .message(let message):
            return message.timestamp.dateValue()
        case .reflection(let reflection):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter.date(from: reflection.createdAt) ?? Date()
        }
    }
    
    static func == (lhs: ChatContent, rhs: ChatContent) -> Bool {
        switch (lhs, rhs) {
        case (.message(let m1), .message(let m2)):
            return m1 == m2
        case (.reflection(let r1), .reflection(let r2)):
            return r1 == r2
        default:
            return false
        }
    }
}

// Main ChatView
struct ChatView: View {
    let artPieceID: UUID
    @StateObject var userManager: UserManager
    @State private var newMessage = ""
    @State private var messages = [Message]()
    @State private var artPiece: ArtPiece?
    @State private var selectedMediaType: ReflectionMediaType = .text
    @State private var selectedItem: PhotosPickerItem?
    @StateObject private var reflectionViewModel = ReflectionViewModel()
    
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
                
                // Combined messages and reflections view
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        if messages.isEmpty && reflectionViewModel.reflections.isEmpty {
                            EmptyMessagesView()
                        }
                        
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(sortedContent) { item in
                                switch item {
                                case .message(let message):
                                    MessageView(
                                        message: message,
                                        isFromCurrentUser: message.userId == userManager.currentUser?.uid,
                                        dateFormatter: dateFormatter,
                                        deleteAction: {
                                            if let messageId = message.id {
                                                deleteMessage(messageID: messageId)
                                            }
                                        }
                                    )
                                case .reflection(let reflection):
                                    ReflectionBubble(reflection: reflection, userManager: userManager)
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: sortedContent) { _, _ in
                        if let lastId = sortedContent.last?.id {
                            scrollViewProxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 8) {
                    Picker("Type", selection: $selectedMediaType) {
                        ForEach(ReflectionMediaType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    switch selectedMediaType {
                    case .text:
                        MessageInputView(newMessage: $newMessage, onSend: sendMessage)
                    case .photo:
                        MediaPickerView(
                            type: .photo,
                            selectedItem: $selectedItem,
                            onSubmit: submitMediaReflection
                        )
                    case .video:
                        MediaPickerView(
                            type: .video,
                            selectedItem: $selectedItem,
                            onSubmit: submitMediaReflection
                        )
                    case .audio:
                        Text("Audio coming soon")
                            .foregroundColor(.secondary)
                    }
                }
                .background(Color.black.opacity(0.2))
            }
        }
        .task {
            await loadArtPiece()
            loadMessages()
            await reflectionViewModel.loadReflections(for: artPieceID)
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
    
    // Combined and sorted content
    private var sortedContent: [ChatContent] {
        var content: [ChatContent] = []
        content.append(contentsOf: messages.map { ChatContent.message($0) })
        content.append(contentsOf: reflectionViewModel.reflections.map { ChatContent.reflection($0) })
        return content.sorted { item1, item2 in
            let date1 = item1.date
            let date2 = item2.date
            return date1 < date2
        }
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
    
    private func submitMediaReflection() {
        guard let userId = userManager.currentUser?.uid,
              let item = selectedItem else { return }
        
        Task {
            do {
                let token = try await Auth.auth().currentUser?.getIDToken() ?? ""
                print("📤 Starting \(selectedMediaType) upload...")
                await reflectionViewModel.addMediaReflection(
                    artifactId: artPieceID,
                    userId: userId,
                    item: item,
                    type: selectedMediaType,
                    firebaseToken: token
                )
                await MainActor.run {
                    selectedItem = nil
                }
                print("✅ Upload completed successfully")
            } catch {
                print("❌ Failed to upload media: \(error)")
                // Show error to user
                // TODO: Add error alert
            }
        }
    }
}

// Helper view for media selection
struct MediaPickerView: View {
    let type: ReflectionMediaType
    @Binding var selectedItem: PhotosPickerItem?
    let onSubmit: () -> Void
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: type == .photo ? .images : .videos,
                photoLibrary: .shared()
            ) {
                Label(
                    type == .photo ? "Select Photo" : "Select Video",
                    systemImage: type == .photo ? "photo" : "video"
                )
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            .onChange(of: selectedItem) { _, _ in
                // Clear selection if user cancels
                if selectedItem == nil {
                    print("Selection was cancelled")
                }
            }
            
            if selectedItem != nil {
                Button(type == .photo ? "Upload Photo" : "Upload Video") {
                    onSubmit()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.bottom)
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

// Add this after the MediaPickerView
struct ReflectionBubble: View {
    let reflection: ArtifactReflection
    let userManager: UserManager
    
    private var isCurrentUser: Bool {
        reflection.userId == userManager.currentUser?.uid
    }
    
    private var username: String {
        if isCurrentUser {
            return userManager.currentUser?.displayName ?? 
                   userManager.currentUser?.email ?? 
                   "Me"
        } else {
            return "User"  // TODO: Implement user lookup
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = isoFormatter.date(from: reflection.createdAt) {
            return formatter.string(from: date)
        }
        return reflection.createdAt
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 8) {
                    switch reflection.reflectionType {
                    case "text":
                        Text(reflection.textContent)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    case "image":
                        if let mediaUrl = reflection.mediaUrl,
                           let url = URL(string: mediaUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 150)
                                        .cornerRadius(8)
                                case .failure(_):
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(.red)
                                        .frame(height: 150)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                    case "video":
                        if let mediaUrl = reflection.mediaUrl,
                           let url = URL(string: mediaUrl) {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                        
                    default:
                        Text("Unsupported media type")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
                .background(isCurrentUser ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                .cornerRadius(12)
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
