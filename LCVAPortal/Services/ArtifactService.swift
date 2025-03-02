import Foundation

class ArtifactService {
    static let shared = ArtifactService()  // Singleton
    private let client = SupabaseClient.shared
    
    private init() {}
    
    func fetchAllArtifacts() async throws -> [Artifact] {
        let data = try await client.makeRequestWithResponse(
            endpoint: "rpc/get_all_artifacts",
            method: "GET"
        )
        return try JSONDecoder().decode([Artifact].self, from: data)
    }
    
    // Add more specific fetch methods as needed
    func fetchFeaturedArtifacts() async throws -> [Artifact] {
        return try await fetchAllArtifacts().filter { $0.featured }
    }
    
    func fetchOnDisplayArtifacts() async throws -> [Artifact] {
        return try await fetchAllArtifacts().filter { $0.on_display }
    }
    
    func fetchArtifactsByCollection(collectionName: String) async throws -> [Artifact] {
        let data = try await client.makeRequestWithResponse(
            endpoint: "rpc/get_artifacts_by_collection",
            method: "POST",
            body: try JSONSerialization.data(withJSONObject: ["collection_name": collectionName])
        )
        return try JSONDecoder().decode([Artifact].self, from: data)
    }
} 