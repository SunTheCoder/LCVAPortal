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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reflections")
                .font(.headline)
                .foregroundColor(.white)
            
            // Media type selector
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
            
            // Reflections list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.reflections) { reflection in
                        ReflectionItemView(reflection: reflection)
                    }
                }
            }
        }
        .padding()
        .task {
            await viewModel.loadReflections(for: artifactId)
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
        // Convert ISO string to formatted date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: reflection.createdAt) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return reflection.createdAt
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Show different content based on reflection type
            switch reflection.reflectionType {
            case "text":
                Text(reflection.textContent)
                    .foregroundColor(.white)
                
            case "image":
                if let url = URL(string: reflection.mediaUrl ?? "") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
            case "video":
                if let url = URL(string: reflection.mediaUrl ?? "") {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                }
                
            default:
                Text("Unsupported media type")
                    .foregroundColor(.secondary)
            }
            
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
} 