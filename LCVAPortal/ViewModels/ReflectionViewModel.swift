import Foundation
import PhotosUI
import SwiftUI

@MainActor
class ReflectionViewModel: ObservableObject {
    @Published var reflections: [ArtifactReflection] = []
    @Published var isUploading = false
    private let supabase = SupabaseClient.shared
    
    func loadReflections(for artifactId: UUID) async {
        do {
            reflections = try await supabase.fetchReflections(for: artifactId)
        } catch {
            print("❌ Failed to load reflections: \(error)")
        }
    }
    
    func addReflection(artifactId: UUID, userId: String, textContent: String) async {
        do {
            try await supabase.addReflection(
                artifactId: artifactId,
                userId: userId,
                textContent: textContent
            )
            // Reload reflections after adding
            await loadReflections(for: artifactId)
        } catch {
            print("❌ Failed to add reflection: \(error)")
        }
    }
    
    func addMediaReflection(
        artifactId: UUID,
        userId: String,
        item: PhotosPickerItem,
        type: ReflectionMediaType,
        firebaseToken: String
    ) async {
        isUploading = true
        defer { isUploading = false }
        
        do {
            // Load and process the media
            let (data, fileType) = try await loadMediaData(from: item, type: type)
            
            // Generate unique filename with proper extension
            let fileExtension = type == .photo ? "jpg" : "mp4"
            let fileName = "\(UUID().uuidString).\(fileExtension)"
            
            // Upload to Supabase Storage
            let mediaUrl = try await supabase.uploadReflectionMedia(
                fileData: data,
                fileName: fileName,
                fileType: fileType,
                firebaseToken: firebaseToken
            )
            
            // Create reflection with media URL - ensure correct reflection_type
            try await supabase.addReflection(
                artifactId: artifactId,
                userId: userId,
                reflectionType: type == .photo ? "image" : "video",
                textContent: "",
                mediaUrl: mediaUrl
            )
            
            await loadReflections(for: artifactId)
            
        } catch {
            print("❌ Failed to add media reflection: \(error)")
        }
    }
    
    private func loadMediaData(from item: PhotosPickerItem, type: ReflectionMediaType) async throws -> (Data, String) {
        switch type {
        case .photo:
            if let data = try await item.loadTransferable(type: Data.self) {
                return (data, "image/jpeg")
            }
        case .video:
            if let data = try await item.loadTransferable(type: Data.self) {
                return (data, "video/mp4")
            }
        default:
            break
        }
        
        throw NSError(domain: "ReflectionError", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to load media data"
        ])
    }
} 