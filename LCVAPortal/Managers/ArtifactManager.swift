import Foundation

@MainActor
class ArtifactManager: ObservableObject {
    static let shared = ArtifactManager()
    private let artifactService = ArtifactService.shared
    
    @Published var artifacts: [Artifact] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func preloadArtifacts() async {
        guard artifacts.isEmpty else { return }  // Only load if not already loaded
        
        isLoading = true
        do {
            artifacts = try await artifactService.fetchAllArtifacts()
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
} 