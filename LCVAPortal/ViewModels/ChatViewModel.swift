import Foundation
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let db = Firestore.firestore()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var memoryCache: [UUID: [Message]] = [:]
    
    init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDirectory.appendingPathComponent("chat_cache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        print("📁 Chat cache directory: \(cacheDirectory.path)")
    }
    
    func loadMessages(for artifactId: UUID) async {
        // Try cache first
        if let cached = getCachedMessages(for: artifactId) {
            print("📱 Using \(cached.count) cached messages")
            messages = cached
        }
        
        let messagesRef = db.collection("chats")
            .document(artifactId.uuidString)
            .collection("messages")
            .order(by: "timestamp", descending: false)
        
        messagesRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let newMessages = documents.compactMap { document -> Message? in
                try? document.data(as: Message.self)
            }
            
            self?.messages = newMessages
            self?.cacheMessages(newMessages, for: artifactId)
        }
    }
    
    private func cacheMessages(_ messages: [Message], for artifactId: UUID) {
        print("📝 Caching \(messages.count) messages for: \(artifactId.uuidString.prefix(8))")
        
        // Cache in memory
        memoryCache[artifactId] = messages
        
        // Cache to disk
        let url = cacheDirectory.appendingPathComponent("\(artifactId.uuidString).json")
        
        do {
            // Convert to cacheable format
            let cacheable = messages.map { message -> [String: Any] in
                [
                    "id": message.id ?? UUID().uuidString,
                    "userId": message.userId,
                    "username": message.username,
                    "text": message.text,
                    "timestamp": message.timestamp.dateValue().timeIntervalSince1970,
                    "artPieceID": message.artPieceID
                ]
            }
            let data = try JSONSerialization.data(withJSONObject: cacheable)
            try data.write(to: url)
            print("💾 Cached messages to disk")
        } catch {
            print("❌ Failed to cache messages:", error)
        }
    }
    
    private func getCachedMessages(for artifactId: UUID) -> [Message]? {
        // Check memory cache first
        if let cached = memoryCache[artifactId] {
            print("💭 Memory cache hit for: \(artifactId.uuidString.prefix(8))")
            return cached
        }
        
        // Try disk cache
        let url = cacheDirectory.appendingPathComponent("\(artifactId.uuidString).json")
        
        do {
            let data = try Data(contentsOf: url)
            let cached = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            let messages = cached.compactMap { dict -> Message? in
                guard let id = dict["id"] as? String,
                      let userId = dict["userId"] as? String,
                      let username = dict["username"] as? String,
                      let text = dict["text"] as? String,
                      let timestamp = dict["timestamp"] as? TimeInterval,
                      let artPieceID = dict["artPieceID"] as? String
                else { return nil }
                
                return Message(
                    id: id,
                    username: username,
                    userId: userId,
                    text: text,
                    timestamp: Timestamp(date: Date(timeIntervalSince1970: timestamp)),
                    artPieceID: artPieceID
                )
            }
            
            // Update memory cache
            memoryCache[artifactId] = messages
            print("💾 Disk cache hit! Loaded \(messages.count) messages")
            
            return messages
        } catch {
            print("❌ Cache miss for: \(artifactId.uuidString.prefix(8))")
            return nil
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
