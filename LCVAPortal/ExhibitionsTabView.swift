import SwiftUI

struct ExhibitionsTabView: View {
    let exhibitions: [Exhibition]
    
    var body: some View {
        TabView {
            ForEach(exhibitions) { exhibition in
                ScrollView {
                    VStack(spacing: 20) {
                        AsyncImage(url: URL(string: exhibition.imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 300)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(exhibition.title)
                                .font(.title2)
                                .bold()
                            
                            Text(exhibition.artist.joined(separator: ", "))
                                .font(.headline)
                                .italic()
                            
                            Group {
                                Text("Reception:")
                                    .font(.subheadline)
                                    .bold()
                                Text(exhibition.reception)
                                    .font(.subheadline)
                                
                                Text("Closing:")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.top, 8)
                                Text(exhibition.closing)
                                    .font(.subheadline)
                            }
                            
                            Text(exhibition.description)
                                .font(.body)
                                .padding(.top)
                            
                            Link("Survey Link", destination: URL(string: exhibition.surveyUrl)!)
                                .font(.subheadline)
                                .padding(8)
                                .padding(.horizontal, 4)
                                .background(Color.primary.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(7)
                                .shadow(radius: 2)
                        }
                        .padding()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    ExhibitionsTabView(exhibitions: sampleExhibitions)
} 