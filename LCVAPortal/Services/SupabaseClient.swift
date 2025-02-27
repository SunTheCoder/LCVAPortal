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
} 