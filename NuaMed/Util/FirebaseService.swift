import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Username uniqueness
    func isUsernameTaken(_ username: String, completion: @escaping (Bool) -> Void) {
        let ref = db.collection("usernames").document(username.lowercased())
        ref.getDocument { snap, err in
            completion(snap?.exists == true)
        }
    }

    // MARK: - Register
    func register(username: String, email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        isUsernameTaken(username) { taken in
            if taken {
                completion(.failure(NSError(domain: "", code: 409, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])))
                return
            }

            self.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error { completion(.failure(error)); return }
                guard let firebaseUser = result?.user else {
                    completion(.failure(NSError(domain:"", code:-1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])))
                    return
                }

                let profile = NuaMed.User(
                    uid: firebaseUser.uid,
                    username: username,
                    email: email,
                    name: nil,
                    gender: nil,
                    dob: nil,
                    age: nil,
                    allergies: [],
                    medications: [],
                    medicalConditions: [],
                    profileSetup: false,
                    profileImageBase64: nil
                )

                let batch = self.db.batch()
                let usernameRef = self.db.collection("usernames").document(username.lowercased())
                batch.setData(["uid": firebaseUser.uid, "createdAt": FieldValue.serverTimestamp()], forDocument: usernameRef)
                let profileRef = self.db.collection("users").document(firebaseUser.uid)
                batch.setData(profile.toDictionary(), forDocument: profileRef)

                batch.commit { err in
                    if let err = err { completion(.failure(err)) }
                    else { completion(.success(profile)) }
                }
            }
        }
    }

    // MARK: - Login
    func login(usernameOrEmail: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        if usernameOrEmail.contains("@") {
            // Email login
            auth.signIn(withEmail: usernameOrEmail, password: password) { res, err in
                if let err = err { completion(.failure(err)); return }
                guard let firebaseUser = res?.user else {
                    completion(.failure(NSError(domain:"", code:-1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])))
                    return
                }

                // Fetch user profile
                self.db.collection("users").document(firebaseUser.uid).getDocument { snap, err2 in
                    if let err2 = err2 { completion(.failure(err2)); return }
                    guard let data = snap?.data() else {
                        completion(.failure(NSError(domain:"", code:404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                        return
                    }
                    let userProfile = User(from: data)
                    completion(.success(userProfile))
                }
            }
        } else {
            // Username login
            let docRef = db.collection("usernames").document(usernameOrEmail.lowercased())
            docRef.getDocument { snap, err in
                if let err = err { completion(.failure(err)); return }
                guard let data = snap?.data(), let uid = data["uid"] as? String else {
                    completion(.failure(NSError(domain:"", code:404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
                    return
                }

                // Fetch full profile
                self.db.collection("users").document(uid).getDocument { snap2, err2 in
                    if let err2 = err2 { completion(.failure(err2)); return }
                    guard let udata = snap2?.data() else {
                        completion(.failure(NSError(domain:"", code:404, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])))
                        return
                    }

                    // Sign in using email from profile
                    guard let email = udata["email"] as? String else {
                        completion(.failure(NSError(domain:"", code:404, userInfo: [NSLocalizedDescriptionKey: "User email not found"])))
                        return
                    }

                    self.auth.signIn(withEmail: email, password: password) { res3, err3 in
                        if let err3 = err3 { completion(.failure(err3)); return }
                        guard res3?.user != nil else {
                            completion(.failure(NSError(domain:"", code:-1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])))
                            return
                        }

                        let userProfile = User(from: udata)
                        completion(.success(userProfile))
                    }
                }
            }
        }
    }



    // MARK: - Check if profile setup
    func fetchUserProfile(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snap, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let data = snap?.data() else {
                completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            let profile = User(from: data)
            completion(.success(profile))
        }
    }
    
    func fetchUserProfileByUsername(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Check if a document was found
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    
                    // Safely unwrap required fields
                    guard let usernameValue = data["username"] as? String,
                          let emailValue = data["email"] as? String else {
                        completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                        return
                    }
                    
                    let profile = User(
                        uid: document.documentID,
                        username: usernameValue,
                        email: emailValue,
                        name: data["name"] as? String,
                        gender: data["gender"] as? String,
                        dob: (data["dob"] as? Timestamp)?.dateValue(),
                        age: data["age"] as? Int,
                        allergies: data["allergies"] as? [String] ?? [],
                        medications: data["medications"] as? [String] ?? [],
                        medicalConditions: data["medicalConditions"] as? [String] ?? [],
                        profileSetup: data["profileSetup"] as? Bool ?? false,
                        profileImageBase64: data["profileImageBase64"] as? String
                    )
                    
                    completion(.success(profile))
                } else {
                    // Username not found
                    completion(.failure(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
                }
            }
    }


    // MARK: - Save profile
    func saveProfile(uid: String, profile: User, completion: @escaping (Error?) -> Void) {
        var updated = profile.toDictionary()
        updated["profileSetup"] = true
        db.collection("users").document(uid).setData(updated, merge: true, completion: completion)
    }

    // MARK: - Reset password (by email only)
    func sendPasswordReset(toEmail: String, completion: @escaping (Error?) -> Void) {
        auth.sendPasswordReset(withEmail: toEmail, completion: completion)
    }

    // MARK: - Change email/password (reauth)
    func reauthenticateAndChangeEmail(currentPassword: String, newEmail: String, completion: @escaping (Error?) -> Void) {
        guard let user = auth.currentUser, let currentEmail = user.email else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }

        // Check if new email is already in use
        auth.fetchSignInMethods(forEmail: newEmail) { methods, error in
            if let error = error {
                completion(error)
                return
            }
            if let methods = methods, !methods.isEmpty {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email already in use"]))
                return
            }

            // Reauthenticate current user
            let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)
            user.reauthenticate(with: credential) { _, reauthError in
                if let reauthError = reauthError {
                    completion(reauthError)
                    return
                }

                // Update to new email
                user.updateEmail(to: newEmail) { updateError in
                    if let updateError = updateError {
                        completion(updateError)
                        return
                    }

                    // Update in Firestore
                    self.db.collection("users").document(user.uid).setData(["email": newEmail], merge: true) { firestoreError in
                        if let firestoreError = firestoreError {
                            completion(firestoreError)
                            return
                        }

                        // Send verification to new email
                        user.sendEmailVerification { verificationError in
                            completion(verificationError) // nil if success
                        }
                    }
                }
            }
        }
    }

    func reauthenticateAndChangePassword(currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = auth.currentUser, let email = user.email else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, err in
            if let err = err {
                completion(err)
                return
            }
            user.updatePassword(to: newPassword, completion: completion)
        }
    }
    
    // MARK: - Update username
    func updateUsername(uid: String, newUsername: String, completion: @escaping (Error?) -> Void) {
        let usernamesRef = db.collection("usernames")
        
        // First, get the current username of the user
        db.collection("users").document(uid).getDocument { snap, err in
            if let err = err {
                completion(err)
                return
            }
            guard let data = snap?.data(), let oldUsername = data["username"] as? String else {
                completion(NSError(domain:"", code:404, userInfo:[NSLocalizedDescriptionKey:"Current username not found"]))
                return
            }

            let batch = self.db.batch()

            // Delete old username document
            let oldRef = usernamesRef.document(oldUsername.lowercased())
            batch.deleteDocument(oldRef)

            // Set new username document
            let newRef = usernamesRef.document(newUsername.lowercased())
            batch.setData(["uid": uid, "createdAt": FieldValue.serverTimestamp()], forDocument: newRef)

            // Update username in users collection
            let userRef = self.db.collection("users").document(uid)
            batch.setData(["username": newUsername], forDocument: userRef, merge: true)

            batch.commit { err2 in
                completion(err2)
            }
        }
    }
    
    // MARK: - Delete User Account
    func deleteUser(uid: String, completion: @escaping (Error?) -> Void) {
        // First, fetch the user's profile to get the username
        fetchUserProfile(uid: uid) { result in
            switch result {
            case .failure(let err):
                completion(err)
            case .success(let profile):
                let username = profile.username ?? ""
                let batch = self.db.batch()
                
                // Delete user document
                let userRef = self.db.collection("users").document(uid)
                batch.deleteDocument(userRef)
                
                // Delete username document if exists
                if !username.isEmpty {
                    let usernameRef = self.db.collection("usernames").document(username.lowercased())
                    batch.deleteDocument(usernameRef)
                }
                
                // Commit batch deletion in Firestore
                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(batchError)
                        return
                    }
                    
                    // Delete Firebase Auth account
                    guard let user = Auth.auth().currentUser, user.uid == uid else {
                        completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
                        return
                    }
                    
                    user.delete { authError in
                        completion(authError) // nil if success
                    }
                }
            }
        }
    }



    // MARK: - Upload image
    func saveProfileImage(uid: String, image: UIImage?, completion: @escaping (Error?) -> Void) {
        let userDoc = Firestore.firestore().collection("users").document(uid)
        

        print("Saving image")
        if let image = image, let data = image.jpegData(compressionQuality: 0.2) {
            let base64 = data.base64EncodedString()
            userDoc.updateData(["profileImageBase64": base64]) { error in
                print("Saving image error")
                completion(error)
            }
        } else {
            // Remove image from Firestore
            userDoc.updateData(["profileImageBase64": FieldValue.delete()]) { error in
                completion(error)
            }
        }
    }


    func fetchProfileImage(uid: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = snapshot?.data(),
                  let base64 = data["profileImageBase64"] as? String,
                  let imageData = Data(base64Encoded: base64),
                  let image = UIImage(data: imageData) else {
                completion(.success(nil))
                return
            }
            completion(.success(image))
        }
    }

}
