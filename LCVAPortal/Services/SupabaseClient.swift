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
    func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/\(endpoint)") else {
            print("❌ Invalid URL: \(supabaseUrl)/rest/v1/\(endpoint)")
            throw URLError(.badURL)
        }
        
        print("🔍 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = createHeaders()
        request.httpBody = body
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Request body: \(bodyString)")
        }
        
        print("🔑 Headers: \(createHeaders())")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw URLError(.badServerResponse)
        }
        
        print("📊 Status code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Bad status code: \(httpResponse.statusCode)")
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
} 