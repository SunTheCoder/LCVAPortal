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
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            formatter.timeZone = TimeZone(identifier: "UTC")  // Supabase sends UTC
            
            if let utcDate = formatter.date(from: reflection.createdAt) {
                // Convert to Eastern Time
                let easternFormatter = DateFormatter()
                easternFormatter.timeZone = TimeZone(identifier: "America/New_York")
                // print("📅 Converting UTC: \(utcDate) to Eastern: \(easternFormatter.string(from: utcDate))")
                return utcDate
            }
            
            print("⚠️ Failed to parse date: \(reflection.createdAt)")
            return Date()
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
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var artPiece: ArtPiece?
    @State private var selectedMediaType: ReflectionMediaType = .text
    @State private var selectedItem: PhotosPickerItem?
    @StateObject private var reflectionViewModel = ReflectionViewModel()
    @State private var isMediaPickerPresented = false
    
    private let db = Firestore.firestore()
    private let supabase = SupabaseClient.shared
    private let dateFormatter = DateFormatter.shortDateTimeFormatter()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {  // Remove spacing between elements
                if let artPiece = artPiece {
                    ArtPieceHeaderView(artPiece: artPiece)
                }
                
                // Combined messages and reflections view
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        if chatViewModel.messages.isEmpty && reflectionViewModel.reflections.isEmpty {
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
                
                // New combined input view
                ChatInputView(
                    newMessage: $newMessage,
                    selectedMediaType: $selectedMediaType,
                    selectedItem: $selectedItem,
                    isMediaPickerPresented: $isMediaPickerPresented,
                    onSend: sendMessage,
                    onSubmitMedia: submitMediaReflection
                )
                .background(Color.lcvaNavy)  // Solid background
                .shadow(color: .black.opacity(0.2), radius: 5, y: -2)  // Add subtle shadow above
            }
        }
        .task {
            await loadArtPiece()
            await chatViewModel.loadMessages(for: artPieceID)
            await reflectionViewModel.loadReflections(for: artPieceID)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaNavy]),
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
        
        // Convert Firebase timestamps to Date
        let messageContent = chatViewModel.messages.map { message -> ChatContent in
            let date = message.timestamp.dateValue()
            print("📱 Message date: \(date), content: \(message.text)")
            return .message(message)
        }
        
        // Convert Supabase ISO timestamps to Date
        let reflectionContent = reflectionViewModel.reflections.map { reflection -> ChatContent in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = formatter.date(from: reflection.createdAt) ?? Date()
            print("🎨 Reflection date: \(date), type: \(reflection.reflectionType)")
            return .reflection(reflection)
        }
        
        // Combine all content
        content = messageContent + reflectionContent
        print("📊 Total items to sort: \(content.count)")
        
        // Sort by date and ID
        let sorted = content.sorted { item1, item2 in
            let date1 = item1.date
            let date2 = item2.date
            print("🔄 Comparing: \(date1) vs \(date2)")
            
            if date1 == date2 {
                // If dates are equal, sort by ID for stability
                print("📎 Same date, comparing IDs: \(item1.id) vs \(item2.id)")
                return item1.id < item2.id
            }
            return date1 < date2
        }
        
        print("✅ Final sorted count: \(sorted.count)")
        return sorted
    }
    
    // Move the messages view to its own component
    private func loadArtPiece() async {
        do {
            let artifacts = try await supabase.fetchArtifacts()
            if let artifact = artifacts.first(where: { $0.id == artPieceID }) {
                self.artPiece = ArtPiece(
                    id: artifact.id,
                    title: artifact.title,
                    artist: "",
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
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let userId = userManager.currentUser?.uid else {
            return
        }
        
        let username = userManager.currentUser?.displayName ?? "Anonymous"
        
        Task {
            await chatViewModel.sendMessage(
                artifactId: artPieceID,
                userId: userId,
                username: username,
                content: newMessage
            )
            newMessage = ""
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
                    textContent: newMessage,
                    firebaseToken: token
                )
                selectedItem = nil
                isMediaPickerPresented = false
                newMessage = ""
                print("✅ Upload completed successfully")
            } catch {
                print("❌ Failed to upload media: \(error)")
            }
        }
    }
}

// Combined ChatInputView
struct ChatInputView: View {
    @Binding var newMessage: String
    @Binding var selectedMediaType: ReflectionMediaType
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var isMediaPickerPresented: Bool
    
    let onSend: () -> Void
    let onSubmitMedia: () -> Void
    
    @State private var uploadProgress: CGFloat = 0
    @State private var isMediaReady: Bool = false
    
    private var isMessageEmpty: Bool {
        newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Color.clear.frame(height: 8)
            
            Picker("Type", selection: $selectedMediaType) {
                ForEach(ReflectionMediaType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            HStack(alignment: .center, spacing: 12) {
                TextField(selectedMediaType == .text ? "Enter message..." : "Add a caption...", text: $newMessage)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                    .frame(height: 40)
                
                if selectedMediaType != .text {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: selectedMediaType == .photo ? .images : .videos,
                        photoLibrary: .shared()
                    ) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 36, height: 36)
                            
                            Circle()
                                .trim(from: 0, to: uploadProgress)
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: 36, height: 36)
                                .rotationEffect(.degrees(-90))
                                .opacity(selectedItem != nil ? 1 : 0)
                            
                            Image(systemName: selectedMediaType == .photo ? "photo" : "video")
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .opacity(isMediaReady ? 0 : 1)
                            
                            if isMediaReady {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                    .frame(width: 40, height: 40)
                    .onChange(of: selectedItem) { _, newValue in
                        if newValue != nil {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                uploadProgress = 1.0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isMediaReady = true
                                }
                            }
                        } else {
                            withAnimation {
                                uploadProgress = 0
                                isMediaReady = false
                            }
                        }
                    }
                }
                
                Button(action: selectedMediaType == .text ? onSend : onSubmitMedia) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(isMessageEmpty ? .gray : .blue)
                        .font(.system(size: 24))
                        .frame(width: 24, height: 24)
                }
                .frame(width: 40, height: 40)
                .disabled(isMessageEmpty)
                .transition(.scale.combined(with: .opacity))
                .onChange(of: selectedMediaType) { _, _ in
                    withAnimation {
                        uploadProgress = 0
                        isMediaReady = false
                        selectedItem = nil
                    }
                }
            }
            .padding()
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedItem)
        }
        .background(Color.lcvaNavy)
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
            return reflection.username ?? "Anonymous"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        isoFormatter.timeZone = TimeZone(identifier: "UTC")  // Parse as UTC
        
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
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Show media content first if available
                    switch reflection.reflectionType {
                    case "text":
                        Text(reflection.textContent ?? "")
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                    case "image":
                        if let mediaUrl = reflection.mediaUrl,
                           let url = URL(string: mediaUrl) {
                            ChatImageView(url: url)
                            // Show text content below image if not empty
                            if let text = reflection.textContent,
                               !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(text)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 4)
                            }
                        }
                        
                    case "video":
                        if let mediaUrl = reflection.mediaUrl,
                           let url = URL(string: mediaUrl) {
                            VStack {
                                CachedVideoPlayer(
                                    urlString: mediaUrl,
                                    filename: url.lastPathComponent
                                )
                                .frame(height: 200)
                                .cornerRadius(8)
                                .contentShape(Rectangle())
                            }
                            .clipped()
                            // Show text content below video if not empty
                            if let text = reflection.textContent,
                               !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(text)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 4)
                            }
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

// Add this new view at the top level
struct ChatImageView: View {
    let url: URL
    @State private var isExpanded = false
    
    var body: some View {
        // Container to isolate tap gesture
        VStack {
            CachedImageView(
                urlString: url.absoluteString,
                filename: url.lastPathComponent
            )
            .frame(maxHeight: isExpanded ? 400 : 200)
            .cornerRadius(8)
            .contentShape(Rectangle())  // Make entire frame tappable
        }
        .clipped()  // Prevent content from overflowing
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
                }
            }
    }
}
