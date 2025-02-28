import Foundation

struct ContactFormSubmission: Codable {
    let id: UUID
    let first_name: String
    let last_name: String
    let email: String
    let phone: String?
    let category: String
    let message: String
    let created_at: Date?
    let user_id: String?
    
    init(firstName: String, lastName: String, email: String, phone: String?, category: String, message: String, userId: String? = nil) {
        self.id = UUID()
        self.first_name = firstName
        self.last_name = lastName
        self.email = email
        self.phone = phone
        self.category = category
        self.message = message
        self.created_at = nil // Supabase will set this
        self.user_id = userId
    }
} 