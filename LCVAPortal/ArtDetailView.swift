import SwiftUI
import MapKit

struct ArtDetailView: View {
    let artPiece: ArtPiece
    @ObservedObject var userManager: UserManager
    @ObservedObject var userCollections: UserCollections
    @State private var isMapExpanded = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero Image
                    AsyncImage(url: URL(string: artPiece.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 300)
                            .clipped()
                    } placeholder: {
                        ProgressView()
                            .frame(height: 300)
                    }
                    .padding(.top, 130)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Actions
                        HStack {
                            Text(artPiece.title)
                                .font(.title)
                                .bold()
                            
                            Spacer()
                            
                            // Collection and Favorite buttons
                            HStack(spacing: 16) {
                                Button(action: {
                                    if userCollections.isInCollection(artPiece) {
                                        userCollections.removeFromCollection(artPiece)
                                    } else {
                                        userCollections.addToCollection(artPiece)
                                    }
                                }) {
                                    Image(systemName: userCollections.isInCollection(artPiece) ? "minus.circle.fill" : "plus.circle.fill")
                                        .font(.title2)
                                }
                                
                                Button(action: {
                                    userCollections.toggleFavorite(artPiece)
                                }) {
                                    Image(systemName: userCollections.isFavorite(artPiece) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(userCollections.isFavorite(artPiece) ? .red : .primary)
                                }
                            }
                        }
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            DetailRow(title: "Material", content: artPiece.material)
                            DetailRow(title: "Era", content: artPiece.era)
                            DetailRow(title: "Origin", content: artPiece.origin)
                        }
                        .padding(.vertical)
                        
                        // Description
                        Text("About")
                            .font(.headline)
                        Text(artPiece.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Lore Section
                        if !artPiece.lore.isEmpty {
                            Text("Historical Context")
                                .font(.headline)
                                .padding(.top)
                            Text(artPiece.lore)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Replace the map button with a DisclosureGroup
                        DisclosureGroup(
                            isExpanded: $isMapExpanded,
                            content: {
                                MapViewRepresentable(artPiece: artPiece)
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                                    .padding(.top, 8)
                            },
                            label: {
                                HStack {
                                    Image(systemName: "map")
                                    Text("Location")
                                    Spacer()
                                    Text("View on Map")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                            }
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Update chat section styling
                        VStack(alignment: .leading, spacing: 20) {
                            // Chat section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Discussion")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                ChatView(artPieceID: artPiece.id, userManager: userManager)
                                    .frame(height: 300)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                            }
                            
                            // Reflections section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Reflections")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                
                                ReflectionView(artifactId: artPiece.id, userManager: userManager)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                    
                    // Accessibility & Language Options Section
                    if artPiece.translations != nil || artPiece.audioTour != nil || 
                       artPiece.brailleLabel != nil || artPiece.adaAccessibility != nil {
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Accessibility & Language Options")
                                .font(.headline)
                                .padding(.top)
                            
                            // Translations
                            if let translations = artPiece.translations {
                                DisclosureGroup("Available Translations") {
                                    ForEach(translations) { translation in
                                        HStack {
                                            Text(translation.language)
                                                .font(.subheadline)
                                            Spacer()
                                            NavigationLink {
                                                TranslatedLabelView(translation: translation)
                                            } label: {
                                                Text("View")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            
                            // Audio Tour
                            if let audioTour = artPiece.audioTour {
                                DisclosureGroup("Audio Guide") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(audioTour.title)
                                            .font(.subheadline)
                                        Text("Duration: \(Int(audioTour.duration/60))m \(Int(audioTour.duration.truncatingRemainder(dividingBy: 60)))s")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Button(action: {
                                            // TODO: Play audio or open audio player
                                        }) {
                                            Label("Play Audio", systemImage: "play.circle.fill")
                                        }
                                    }
                                }
                            }
                            
                            // Braille Label
                            if let brailleLabel = artPiece.brailleLabel {
                                DisclosureGroup("Braille Label") {
                                    HStack {
                                        Text("Status: \(brailleLabel.status.rawValue.capitalized)")
                                            .font(.subheadline)
                                        Spacer()
                                        switch brailleLabel.status {
                                        case .available:
                                            Button("Download") {
                                                // TODO: Download braille document
                                            }
                                        case .requestable:
                                            Button("Request") {
                                                // TODO: Request braille document
                                            }
                                        case .inProgress:
                                            Text("Coming Soon")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            // ADA Information
                            if let ada = artPiece.adaAccessibility {
                                DisclosureGroup("ADA Information") {
                                    VStack(alignment: .leading, spacing: 8) {
                                        AccessibilityFeatureRow(
                                            icon: "figure.roll",
                                            text: "Wheelchair Accessible",
                                            isAvailable: ada.isWheelchairAccessible
                                        )
                                        AccessibilityFeatureRow(
                                            icon: "ear",
                                            text: "Audio Description",
                                            isAvailable: ada.hasAudioDescription
                                        )
                                        AccessibilityFeatureRow(
                                            icon: "hand.raised.fill",
                                            text: "Tactile Elements",
                                            isAvailable: ada.hasTactileElements
                                        )
                                        if let notes = ada.additionalNotes {
                                            Text(notes)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}


// Helper view for ADA features
struct AccessibilityFeatureRow: View {
    let icon: String
    let text: String
    let isAvailable: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isAvailable ? .green : .secondary)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isAvailable ? .green : .secondary)
        }
    }
} 