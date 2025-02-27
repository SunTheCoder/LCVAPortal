//
//  UserManager.swift
//  LCVAPortal
//
//  Created by Sun English on 11/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class UserManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    private var db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Store the auth state listener handle
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = user != nil
            self?.currentUser = user
        }
    }
    
    deinit {
        // Remove the auth state listener when UserManager is deinitialized
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(email: String, password: String, name: String, preferences: [String]) async throws {
        do {
            // 1. Create Firebase user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // 2. Set display name
            let changeRequest = authResult.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // 3. Update UI on main thread
            await MainActor.run {
                self.currentUser = authResult.user
                self.isLoggedIn = true
            }

            print("📝 Creating user documents...")

            // 4. Create Firestore document FIRST (since we need this for app functionality)
            let userProfile = [
                "name": name,
                "email": email,
                "preferences": preferences,
                "role": "user"
            ] as [String: Any]

            try await self.db.collection("users")
                .document(authResult.user.uid)
                .setData(userProfile)
            
            print("✅ Firestore document created")

            // 5. Create user in Supabase (as backup/secondary storage)
            let supabaseUser = SupabaseUser(
                id: authResult.user.uid,
                email: email,
                name: name,
                created_at: Date()
            )
            
            try await SupabaseClient.shared.createUser(supabaseUser)
            print("✅ Supabase user created")
            
            print("✨ User profile saved successfully in both Firestore and Supabase!")
            
        } catch {
            print("❌ Error during sign up: \(error.localizedDescription)")
            throw error
        }
    }

    func logIn(email: String, password: String) async {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Update UI on main thread
            await MainActor.run {
                self.currentUser = authResult.user
                self.isLoggedIn = true
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
            currentUser = nil
        } catch let error {
            print("Error logging out: \(error.localizedDescription)")
        }
    }

    // MARK: - Chat Message Functions

    // Function to reply to a message
    func replyToMessage(chatID: String, messageID: String, replyText: String) {
        guard let userID = currentUser?.uid else {
            print("User is not logged in")
            return
        }

        let replyData: [String: Any] = [
            "text": replyText,
            "senderID": userID,
            "timestamp": Timestamp()
        ]

        db.collection("chats").document(chatID).collection("messages").document(messageID).collection("replies").addDocument(data: replyData) { error in
            if let error = error {
                print("Error replying to message: \(error.localizedDescription)")
            } else {
                print("Reply added successfully!")
            }
        }
    }

    // Function to delete a message (admin-only)
    func deleteMessage(chatID: String, messageID: String, completion: @escaping (Bool) -> Void) {
        // Check if the current user is an admin
        guard let userID = currentUser?.uid else {
            print("User is not logged in")
            completion(false)
            return
        }

        // Fetch the user's role from Firestore
        db.collection("users").document(userID).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let document = document, let data = document.data(), let role = data["role"] as? String, role == "admin" else {
                print("User does not have admin privileges")
                completion(false)
                return
            }

            // Delete the message if the user is an admin
            self?.db.collection("chats").document(chatID).collection("messages").document(messageID).delete { error in
                if let error = error {
                    print("Error deleting message: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Message deleted successfully!")
                    completion(true)
                }
            }
        }
    }
}
