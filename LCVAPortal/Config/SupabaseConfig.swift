import Foundation

enum SupabaseConfig {
    static func setupEnvironment() {
        // Load from .env file
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil) {
            let envContents = try? String(contentsOfFile: envPath, encoding: .utf8)
            envContents?.components(separatedBy: .newlines).forEach { line in
                let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    setenv(key, value, 1)
                }
            }
        }
    }
} 