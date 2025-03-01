import Foundation

class SupabaseClient {
    static let shared = SupabaseClient()
    
    private let supabaseUrl: String
    private let supabaseAnonKey: String
    
    private init() {
        // Load from environment variables or configuration
        guard let url = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] else {
            fatalError("Missing Supabase configuration. Ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.")
        }
        
        self.supabaseUrl = url
        self.supabaseAnonKey = key
    }
    
    func createHeaders() -> [String: String] {
        return [
            "apikey": supabaseAnonKey,
            "Content-Type": "application/json"
        ]
    }
    
    // Single makeRequest function that can handle both data and void responses
    private func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        headers: [String: String]? = nil
    ) async throws {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/\(endpoint)") else {
            print("❌ Invalid URL: \(supabaseUrl)/rest/v1/\(endpoint)")
            throw URLError(.badURL)
        }
        
        print("🔍 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add base headers
        var allHeaders = createHeaders()
        
        // Add any additional headers
        headers?.forEach { key, value in
            allHeaders[key] = value
        }
        
        request.allHTTPHeaderFields = allHeaders
        request.httpBody = body
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Request body: \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw URLError(.badServerResponse)
        }
    }
    
    func createUser(_ user: SupabaseUser) async throws {
        let jsonData = try JSONEncoder().encode(user)
        try await makeRequest(
            endpoint: "users",
            method: "POST",
            body: jsonData
        )
    }
    
    func fetchArtifacts() async throws -> [Artifact] {
        let data = try await makeRequestWithResponse(
            endpoint: "artifacts",
            method: "GET"
        )
        return try JSONDecoder().decode([Artifact].self, from: data)
    }
    
    func fetchCollections() async throws -> [Collection] {
        let data = try await makeRequestWithResponse(
            endpoint: "collections",
            method: "GET"
        )
        return try JSONDecoder().decode([Collection].self, from: data)
    }
    
    func fetchExhibitions() async throws -> [Exhibition] {
        // First fetch exhibitions
        let exhibitionsData = try await makeRequestWithResponse(
            endpoint: "exhibitions?select=*",
            method: "GET"
        )
        
        // Then fetch exhibition_artists
        let artistsData = try await makeRequestWithResponse(
            endpoint: "exhibition_artists?select=*",
            method: "GET"
        )
        
        let decoder = JSONDecoder()
        
        // Decode both sets of data
        var exhibitions = try decoder.decode([Exhibition].self, from: exhibitionsData)
        let artists = try decoder.decode([ExhibitionArtist].self, from: artistsData)
        
        // Group artists by exhibition_id
        let artistsByExhibition = Dictionary(grouping: artists) { $0.exhibition_id }
        
        // Attach artists to their exhibitions
        for i in exhibitions.indices {
            if let exhibitionArtists = artistsByExhibition[exhibitions[i].id] {
                exhibitions[i].artist = exhibitionArtists.map { $0.artist_name }
            } else {
                exhibitions[i].artist = []
            }
        }
        
        return exhibitions
    }
    
    // Add this struct to decode exhibition_artists
    struct ExhibitionArtist: Codable {
        let id: UUID
        let exhibition_id: UUID
        let artist_name: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case exhibition_id
            case artist_name
        }
    }
    
    // Add a method that returns data for decoding
    private func makeRequestWithResponse(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> Data {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/\(endpoint)") else {
            print("❌ Invalid URL: \(supabaseUrl)/rest/v1/\(endpoint)")
            throw URLError(.badURL)
        }
        
        print("🔍 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = createHeaders()
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func submitContactForm(_ submission: ContactFormSubmission) async throws {
        let endpoint = "contact_form_submissions"
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(submission)
        
        try await makeRequest(
            endpoint: endpoint,
            method: "POST",
            body: body
        )
    }
    
    func fetchArtifactsByCollection(collectionName: String) async throws -> [Artifact] {
        // URL encode the collection name to handle spaces and special characters
        guard let encodedCollection = collectionName
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .replacingOccurrences(of: "&", with: "%26") else {
            throw URLError(.badURL)
        }
        
        let endpoint = "artifacts?collection=eq.\(encodedCollection)"
        print("🔍 Making collection request to: \(endpoint)")  // Debug print
        
        let data = try await makeRequestWithResponse(
            endpoint: endpoint,
            method: "GET"
        )
        
        return try JSONDecoder().decode([Artifact].self, from: data)
    }
    
    // Fetch user's collections
    func fetchUserCollections(userId: String) async throws -> [UserCollection] {
        let endpoint = "user_collections?user_id=eq.\(userId)"
        let data = try await makeRequestWithResponse(endpoint: endpoint)
        return try JSONDecoder().decode([UserCollection].self, from: data)
    }
    
    // Fetch artifacts in a collection
    func fetchCollectionArtifacts(collectionId: UUID) async throws -> [Artifact] {
        let endpoint = "user_collection_artifacts?collection_id=eq.\(collectionId.uuidString)&select=artifact_id"
        let data = try await makeRequestWithResponse(endpoint: endpoint)
        let artifactRefs = try JSONDecoder().decode([ArtifactReference].self, from: data)
        
        guard !artifactRefs.isEmpty else {
            return []
        }
        
        let artifactIds = artifactRefs.map { $0.artifact_id.uuidString }.joined(separator: ",")
        let artifactsEndpoint = "artifacts?id=in.(\(artifactIds))"
        let artifactsData = try await makeRequestWithResponse(endpoint: artifactsEndpoint)
        return try JSONDecoder().decode([Artifact].self, from: artifactsData)
    }
    
    // Helper struct to decode the artifact references
    private struct ArtifactReference: Codable {
        let artifact_id: UUID
    }
    
    // Create user collections
    func createUserCollections(userId: String) async throws -> (personal: UUID, favorites: UUID) {
        let personal = try await createCollection(
            userId: userId,
            name: "Personal",
            description: "My personal collection"
        )
        
        let favorites = try await createCollection(
            userId: userId,
            name: "Favorites",
            description: "My favorite pieces"
        )
        
        return (personal, favorites)
    }
    
    private func createCollection(userId: String, name: String, description: String) async throws -> UUID {
        let endpoint = "user_collections"
        
        let collection = [
            "user_id": userId,
            "name": name,
            "description": description
        ]
        
        let body = try JSONSerialization.data(withJSONObject: collection)
        let data = try await makeRequestWithResponse(endpoint: endpoint, method: "POST", body: body)
        let createdCollection = try JSONDecoder().decode(UserCollection.self, from: data)
        return createdCollection.id
    }
    
    // Add artifact to collection
    func addArtifactToCollection(artifactId: UUID, collectionId: UUID) async throws {
        let endpoint = "user_collection_artifacts"
        
        print("🔗 Adding artifact to Supabase")
        print("📍 Artifact ID: \(artifactId)")
        print("📍 Collection ID: \(collectionId)")
        
        let entry = [
            "id": UUID().uuidString,
            "collection_id": collectionId.uuidString,
            "artifact_id": artifactId.uuidString,
            "is_favorite": false
        ] as [String : Any]
        
        let body = try JSONSerialization.data(withJSONObject: entry)
        print("📦 Request body: \(String(data: body, encoding: .utf8) ?? "")")
        
        let headers = [
            "Prefer": "return=representation"
        ]
        
        do {
            try await makeRequest(
                endpoint: endpoint,
                method: "POST",
                body: body,
                headers: headers
            )
            print("✅ Successfully added to Supabase")
        } catch {
            print("❌ Supabase error: \(error)")
            throw error
        }
    }
    
    // Remove artifact from collection
    func removeArtifactFromCollection(artifactId: UUID, collectionId: UUID) async throws {
        let endpoint = "user_collection_artifacts?collection_id=eq.\(collectionId.uuidString)&artifact_id=eq.\(artifactId.uuidString)"
        try await makeRequest(endpoint: endpoint, method: "DELETE")
    }
    
    // Update favorite status for an artifact in collection
    func updateArtifactFavoriteStatus(artifactId: UUID, collectionId: UUID, isFavorite: Bool) async throws {
        print("⭐️ Updating favorite status for artifact \(artifactId)")
        let endpoint = "user_collection_artifacts?collection_id=eq.\(collectionId.uuidString)&artifact_id=eq.\(artifactId.uuidString)"
        
        let entry = [
            "is_favorite": isFavorite
        ]
        
        let body = try JSONSerialization.data(withJSONObject: entry)
        
        try await makeRequest(
            endpoint: endpoint,
            method: "PATCH",
            body: body
        )
        print("✅ Successfully updated favorite status")
    }
} 
