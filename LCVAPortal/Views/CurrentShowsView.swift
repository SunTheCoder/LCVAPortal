import SwiftUI

struct CurrentShowsView: View {
    @State private var exhibitions: [Exhibition] = []
    @State private var isLoading = false
    @State private var error: String?
    @Binding var hasScrolledToInitialPositionCurrent: Bool
    
    // Date formatter for display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Shows")
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.white)
            
            if isLoading {
                ProgressView()
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if exhibitions.filter({ $0.current }).isEmpty {
                Text("No current exhibitions")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ScrollViewReader { scrollProxy in
                    HStack(spacing: 16) {
                        // Left arrow
                        Button(action: {
                            withAnimation {
                                let currentIndex = getCurrentIndex()
                                let newIndex = max(currentIndex - 1, 0)
                                scrollProxy.scrollTo(newIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        // ScrollView content
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                Spacer()
                                    .frame(width: 120)
                                
                                ForEach(Array(exhibitions.filter { $0.current }.enumerated()), id: \.element.id) { index, exhibition in
                                    VStack(alignment: .leading, spacing: 4) {
                                        AsyncImage(url: URL(string: exhibition.image_url ?? "")) { image in
                                            NavigationLink(destination: ExhibitionView(exhibition: exhibition)) {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .shadow(radius: 2)
                                            }
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 120, height: 120)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(exhibition.name)
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.white)
                                                .lineLimit(3)
                                                .frame(width: 120, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Text(exhibition.artist.joined(separator: ", "))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                                .lineLimit(3)
                                                .frame(width: 120, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .frame(height: 70)
                                    }
                                    .frame(width: 120)
                                    .id(index)
                                }
                                
                                Spacer()
                                    .frame(width: 120)
                            }
                            .padding(.horizontal, 8)
                        }
                        .task {
                            if !hasScrolledToInitialPositionCurrent {
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                withAnimation(.easeOut(duration: 0.3)) {
                                    scrollProxy.scrollTo(0, anchor: .leading)
                                }
                                hasScrolledToInitialPositionCurrent = true
                            }
                        }
                        
                        // Right arrow
                        Button(action: {
                            withAnimation {
                                let currentIndex = getCurrentIndex()
                                let newIndex = min(currentIndex + 1, exhibitions.filter { $0.current }.count - 1)
                                scrollProxy.scrollTo(newIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .task {
            do {
                isLoading = true
                exhibitions = try await SupabaseClient.shared.fetchExhibitions()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    private func getCurrentIndex() -> Int {
        0 // This is a simple implementation
    }
} 