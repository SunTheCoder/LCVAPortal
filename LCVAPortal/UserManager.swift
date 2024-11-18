//
//  UserManager.swift
//  LCVAPortal
//
//  Created by Sun English on 11/15/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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

    func signUp(email: String, password: String, name: String, preferences: [String]) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                // Update the display name for the Firebase user
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error setting display name: \(error.localizedDescription)")
                    } else {
                        print("Display name set successfully")
                    }
                }

                // Prepare user profile data for Firestore
                let userProfile = [
                    "name": name,
                    "email": email,
                    "preferences": preferences,
                    "role": "user"
                ] as [String: Any]

                // Save profile data to Firestore
                self.db.collection("users").document(user.uid).setData(userProfile) { error in
                    if let error = error {
                        print("Error saving user profile: \(error.localizedDescription)")
                    } else {
                        print("User profile saved successfully!")
                    }
                }
            }
        }
    }


        func logIn(email: String, password: String) {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error logging in: \(error.localizedDescription)")
                } else {
                    print("User logged in successfully!")
                }
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
