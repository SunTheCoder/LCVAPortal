import SwiftUI

struct MoodInputView: View {
    @State private var mood: String = ""
    @Binding var recommendedArt: [ArtPiece] // Uses your existing ArtPiece model
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling today?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)

            TextField("Enter your mood (e.g., happy, calm)", text: $mood)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                fetchRecommendedArt(for: mood)
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Get Recommendations")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading || mood.isEmpty)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            if !recommendedArt.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recommended Art:")
                        .font(.headline)
                    ForEach(recommendedArt) { art in
                        Text("• \(art.title)")
                            .font(.body)
                        Text("Description: \(art.description)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .padding()
    }

    func fetchRecommendedArt(for mood: String) {
        // Basic input validation
        let sanitizedMood = mood.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedMood.isEmpty else {
            errorMessage = "Please enter a mood"
            return
        }
        
        guard sanitizedMood.count < 100 else {
            errorMessage = "Input too long"
            return
        }
        
        guard let url = URL(string: "https://lcva-ai.onrender.com/recommend") else {
            errorMessage = "Invalid backend URL"
            return
        }

        isLoading = true
        errorMessage = nil

        let requestBody: [String: String] = ["emotion": sanitizedMood]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            self.errorMessage = "Failed to encode request"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to fetch recommendations: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid server response"
                    print("Error: No valid HTTP response")
                    return
                }

                print("HTTP Status Code: \(httpResponse.statusCode)")

                guard httpResponse.statusCode == 200, let data = data else {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    print("Response error: \(httpResponse.statusCode)")
                    return
                }

                // Log raw response before parsing
                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawResponse)")
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let success = json?["success"] as? Bool, success,
                       let resultString = json?["result"] as? String {
                        
                        // Parse result string into ArtPiece objects
                        let artPieces = parseArtPieces(from: resultString)
                        self.recommendedArt = artPieces
                    } else {
                        self.errorMessage = "Unexpected response format"
                    }
                } catch {
                    self.errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                    print("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    /// Parses the AI response into an array of `ArtPiece`, filling in missing fields with defaults.
    func parseArtPieces(from resultString: String) -> [ArtPiece] {
        let pattern = #"(\d+)\.\s+"#  // Match numbered items like "1. ", "2. "
        let splitResults = resultString.components(separatedBy: .newlines).filter { !$0.isEmpty }

        var artPieces: [ArtPiece] = []
        var currentTitle: String?
        var currentDescription: String = ""

        for line in splitResults {
            if line.range(of: pattern, options: .regularExpression) != nil {
                // If we found a new title, save the previous one
                if let title = currentTitle {
                    let newArtPiece = ArtPiece(
                        id: artPieces.count + 1, // Assign incremental ID
                        title: title,
                        description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                        imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/default.jpg", // Placeholder
                        latitude: 37.2973,  // Default location (update if needed)
                        longitude: -78.3967, // Default location (update if needed)
                        material: "Unknown",
                        era: "Unknown",
                        origin: "Unknown",
                        lore: "No lore available."
                    )
                    artPieces.append(newArtPiece)
                }
                // Start new entry
                currentTitle = String(line.dropFirst(3)) // Remove "1. ", "2. "
                currentDescription = ""
            } else {
                // It's part of the description
                currentDescription += (currentDescription.isEmpty ? "" : " ") + line
            }
        }

        // Append the last entry
        if let title = currentTitle {
            let newArtPiece = ArtPiece(
                id: artPieces.count + 1,
                title: title,
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrl: "https://lcva.longwood.edu/wp-content/uploads/2024/08/default.jpg", // Placeholder
                latitude: 37.2973,
                longitude: -78.3967,
                material: "Unknown",
                era: "Unknown",
                origin: "Unknown",
                lore: "No lore available."
            )
            artPieces.append(newArtPiece)
        }

        return artPieces
    }
}
