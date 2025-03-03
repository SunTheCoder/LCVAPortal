import SwiftUI

struct CurrentShowsView: View {
    @EnvironmentObject var exhibitionManager: ExhibitionManager
    @Binding var hasScrolledToInitialPositionCurrent: Bool
    @State private var currentIndex = 0  // Add this to track current position
    
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
            
            if exhibitionManager.isLoading {
                ProgressView()
            } else if let error = exhibitionManager.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if exhibitionManager.currentExhibitions.isEmpty {
                Text("No current exhibitions")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ScrollViewReader { scrollProxy in
                    HStack(spacing: 16) {
                        // Left arrow
                        Button(action: {
                            withAnimation {
                                currentIndex = max(currentIndex - 1, 0)
                                scrollProxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .opacity(currentIndex == 0 ? 0.3 : 1)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == 0)
                        
                        // ScrollView content
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                ForEach(Array(exhibitionManager.currentExhibitions.enumerated()), id: \.element.id) { index, exhibition in
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
                            }
                            .padding(.horizontal, 8)
                        }
                        .onChange(of: currentIndex) { newIndex in
                            withAnimation {
                                scrollProxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                        
                        // Right arrow
                        Button(action: {
                            withAnimation {
                                let maxIndex = exhibitionManager.currentExhibitions.count - 1
                                currentIndex = min(currentIndex + 1, maxIndex)
                                scrollProxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .opacity(currentIndex == exhibitionManager.currentExhibitions.count - 1 ? 0.3 : 1)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .disabled(currentIndex == exhibitionManager.currentExhibitions.count - 1)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
} 