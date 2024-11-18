//
//  MoodInputView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/16/24.
//

//
//  MoodInputView.swift
//  LCVAPortal
//
//  Created by Sun English on 11/16/24.
//

import SwiftUI

struct MoodInputView: View {
    @State private var mood: String = ""
    @Binding var recommendedArt: [ArtPiece] // Bind recommendations to ContentView
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
        guard let url = URL(string: "https://falloutboi.onrender.com/get-recommendations") else {
//            guard let url = URL(string: "http://127.0.0.1:5000/get-recommendations") else {

            errorMessage = "Invalid backend URL"
            return
        }

        isLoading = true
        errorMessage = nil

        let requestBody: [String: String] = ["text": mood] // Adjusted key to match backend input

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { // Ensure UI updates happen on the main thread
                isLoading = false

                if let error = error {
                    errorMessage = "Failed to fetch recommendations: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    errorMessage = "Invalid server response"
                    return
                }

                do {
                    let artPieces = try JSONDecoder().decode([ArtPiece].self, from: data)
                    recommendedArt = artPieces
                } catch {
                    errorMessage = "Failed to decode server response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

}
