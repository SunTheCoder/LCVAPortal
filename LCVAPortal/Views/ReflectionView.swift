import SwiftUI

struct ReflectionView: View {
    let artifactId: UUID
    @StateObject private var viewModel = ReflectionViewModel()
    @State private var newReflection = ""
    @ObservedObject var userManager: UserManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reflections")
                .font(.headline)
                .foregroundColor(.white)
            
            // Add reflection input
            HStack {
                TextField("Share your thoughts...", text: $newReflection)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: submitReflection) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .disabled(newReflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    
    private func submitReflection() {
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
}

struct ReflectionItemView: View {
    let reflection: ArtifactReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reflection.textContent)
                .foregroundColor(.white)
            
            Text(reflection.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
    }
} 