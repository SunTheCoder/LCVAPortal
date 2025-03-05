import SwiftUI
import AVKit  // Add this import for VideoPlayer
import PhotosUI
import FirebaseAuth

struct ReflectionView: View {
    let artifactId: UUID
    @StateObject private var viewModel = ReflectionViewModel()
    @State private var newReflection = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedMediaType: ReflectionMediaType = .text
    @ObservedObject var userManager: UserManager
    @State private var isShowingAllReflections = false
    @State private var showingInputControls = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(isShowingAllReflections ? "Community Journal" : "My Journal")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    isShowingAllReflections.toggle()
                } label: {
                    Label(
                        isShowingAllReflections ? "Show Mine" : "Show All",
                        systemImage: isShowingAllReflections ? "person" : "person.3"
                    )
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            
            // Add reflection button
            Button {
                showingInputControls.toggle()
            } label: {
                Label(
                    showingInputControls ? "Close" : "Add Entry",
                    systemImage: showingInputControls ? "xmark.circle" : "plus.circle"
                )
                .foregroundColor(.white)
                .padding(8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
            
            // Input controls
            if showingInputControls {
                VStack(spacing: 12) {
                    Picker("Media Type", selection: $selectedMediaType) {
                        ForEach(ReflectionMediaType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Dynamic input based on media type
                    switch selectedMediaType {
                    case .text:
                        // Text input
                        HStack {
                            TextField("Share your thoughts...", text: $newReflection)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: submitTextReflection) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .disabled(newReflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                    case .photo:
                        // Photo picker
                        VStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images
                            ) {
                                Label("Select Photo", systemImage: "photo")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            if selectedItem != nil {
                                Button("Upload Photo") {
                                    submitMediaReflection()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                    case .video:
                        // Video picker
                        VStack {
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .videos
                            ) {
                                Label("Select Video", systemImage: "video")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            if selectedItem != nil {
                                Button("Upload Video") {
                                    submitMediaReflection()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        
                    case .audio:
                        Text("Audio upload coming soon")
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.isUploading {
                        ProgressView("Uploading...")
                            .foregroundColor(.white)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Reflections list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredReflections) { reflection in
                        ReflectionItemView(reflection: reflection)
                            .transition(.opacity)
                    }
                }
            }
        }
        .padding()
        .animation(.spring(), value: showingInputControls)
        .animation(.easeInOut, value: isShowingAllReflections)
        .task {
            await viewModel.loadReflections(for: artifactId)
        }
    }
    
    private var filteredReflections: [ArtifactReflection] {
        if isShowingAllReflections {
            return viewModel.reflections
        } else {
            return viewModel.reflections.filter { reflection in
                reflection.userId == userManager.currentUser?.uid
            }
        }
    }
    
    private func submitTextReflection() {
        guard let userId = userManager.currentUser?.uid else { return }
        Task {
            await viewModel.addReflection(
                artifactId: artifactId,
                userId: userId,
                textContent: newReflection
            )
            newReflection = ""
        }
    }
    
    private func submitMediaReflection() {
        guard let userId = userManager.currentUser?.uid,
              let item = selectedItem else { return }
        
        Task {
            do {
                // Get the Firebase ID token
                let token = try await Auth.auth().currentUser?.getIDToken() ?? ""
                
                await viewModel.addMediaReflection(
                    artifactId: artifactId,
                    userId: userId,
                    item: item,
                    type: selectedMediaType,
                    firebaseToken: token
                )
                selectedItem = nil
            } catch {
                print("❌ Failed to get Firebase token: \(error)")
            }
        }
    }
}

struct ReflectionItemView: View {
    let reflection: ArtifactReflection
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        if let date = formatter.date(from: reflection.createdAt) {
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return reflection.createdAt
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with date and type
            HStack {
                Image(systemName: reflectionTypeIcon)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.bottom, 4)
            
            // Show different content based on reflection type
            switch reflection.reflectionType {
            case "text":
                Text(reflection.textContent)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                
            case "image":
                if let url = URL(string: reflection.mediaUrl ?? "") {
                    ChatImageView(url: url)
                }
                
            case "video":
                if let url = URL(string: reflection.mediaUrl ?? "") {
                    CachedVideoPlayer(
                        urlString: url.absoluteString,
                        filename: url.lastPathComponent
                    )
                }
                
            default:
                Text("Unsupported media type")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
    
    private var reflectionTypeIcon: String {
        switch reflection.reflectionType {
        case "text": return "text.bubble"
        case "image": return "photo"
        case "video": return "video"
        default: return "questionmark.circle"
        }
    }
} 