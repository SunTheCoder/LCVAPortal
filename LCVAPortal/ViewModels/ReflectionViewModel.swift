import Foundation

@MainActor
class ReflectionViewModel: ObservableObject {
    @Published var reflections: [ArtifactReflection] = []
    private let supabase = SupabaseClient.shared
    
    func loadReflections(for artifactId: UUID) async {
        do {
            reflections = try await supabase.fetchReflections(for: artifactId)
        } catch {
            print("❌ Failed to load reflections: \(error)")
        }
    }
    
    func addReflection(artifactId: UUID, userId: String, textContent: String) async {
        do {
            try await supabase.addReflection(
                artifactId: artifactId,
                userId: userId,
                textContent: textContent
            )
            // Reload reflections after adding
            await loadReflections(for: artifactId)
        } catch {
            print("❌ Failed to add reflection: \(error)")
        }
    }
} 