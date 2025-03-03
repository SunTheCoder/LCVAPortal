import SwiftUI

struct PastShowsView: View {
    @EnvironmentObject var exhibitionManager: ExhibitionManager
    @Binding var hasScrolledToInitialPositionPast: Bool
    @State private var pastShowIndex = 0
    
    // Update the date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Shows")
                .font(.system(size: 18))
                .bold()
                .foregroundColor(.white)
            
            if exhibitionManager.isLoading {
                ProgressView()
            } else if let error = exhibitionManager.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if exhibitionManager.pastExhibitions.isEmpty {
                Text("No past exhibitions")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                ScrollViewReader { scrollProxy in
                    HStack(spacing: 16) {
                        // Left arrow
                        Button(action: {
                            withAnimation {
                                pastShowIndex = max(pastShowIndex - 1, 0)
                                scrollProxy.scrollTo(pastShowIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .opacity(pastShowIndex == 0 ? 0.3 : 1)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .disabled(pastShowIndex == 0)
                        
                        // ScrollView content
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 32) {
                                ForEach(Array(exhibitionManager.pastExhibitions.enumerated()), id: \.element.id) { index, exhibition in
                                    VStack(alignment: .leading, spacing: 4) {
                                        NavigationLink(destination: ExhibitionView(exhibition: exhibition)) {
                                            CachedImageView(
                                                urlString: exhibition.image_url ?? "",
                                                filename: "\(exhibition.id)-thumb.jpg"
                                            )
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .shadow(radius: 2)
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
                        .onChange(of: pastShowIndex) { newIndex in
                            withAnimation {
                                scrollProxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                        
                        // Right arrow
                        Button(action: {
                            withAnimation {
                                let maxIndex = exhibitionManager.pastExhibitions.count - 1
                                pastShowIndex = min(pastShowIndex + 1, maxIndex)
                                scrollProxy.scrollTo(pastShowIndex, anchor: .center)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .opacity(pastShowIndex == exhibitionManager.pastExhibitions.count - 1 ? 0.3 : 1)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .disabled(pastShowIndex == exhibitionManager.pastExhibitions.count - 1)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
} 