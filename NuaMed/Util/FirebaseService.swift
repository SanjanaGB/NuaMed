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
    
    //MARK: Favorites and History
    private func userDoc(_ uid: String) -> DocumentReference {
        return db.collection("users").document(uid)
    }

    private func favoritesCollection(_ uid: String) -> CollectionReference {
        return userDoc(uid).collection("favorites")
    }

    private func historyCollection(_ uid: String) -> CollectionReference {
        return userDoc(uid).collection("history")
    }

    //MARK: Favorites
    struct FavoriteItem {
        let id: String          // productId
        let name: String
        let category: String
        let safetyScore: Int
        let ingredientInfoJSON: String
        let safetyJSON: String
    }

    func addFavoriteItem(
        uid: String,
        productId: String,
        name: String,
        category: String,
        safetyScore: Int,
        ingredientInfoJSON: String,
        safetyJSON: String,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "name": name,
            "category": category,
            "safetyScore": safetyScore,
            "ingredientInfoJSON": ingredientInfoJSON,
            "safetyJSON": safetyJSON,
            "addedAt": FieldValue.serverTimestamp()
            
        ]

        
        favoritesCollection(uid)
            .document(productId)
            .setData(data, merge: true, completion: completion)
    }

    func removeFavoriteItem(
        uid: String,
        productId: String,
        completion: @escaping (Error?) -> Void
    ) {
        favoritesCollection(uid)
            .document(productId)
            .delete(completion: completion)
    }

    func fetchFavoriteItems(
        forUserID uid: String,
        completion: @escaping (Result<[FavoriteItem], Error>) -> Void
    ) {
        favoritesCollection(uid)
            .order(by: "addedAt", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let items: [FavoriteItem] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()

                    let name = data["name"] as? String ?? "Empty"

                    let category = data["category"] as? String ?? "General"
                    let safetyScore = data["safetyScore"] as? Int ?? 0

                    let ingredientInfoJSON = data["ingredientInfoJSON"] as? String ?? "{}"
                    let safetyJSON = data["safetyJSON"] as? String ?? "{}"

                    return FavoriteItem(
                        id: doc.documentID,
                        name: name,
                        category: category,
                        safetyScore: safetyScore,
                        ingredientInfoJSON: ingredientInfoJSON,
                        safetyJSON: safetyJSON
                    )
                } ?? []


                completion(.success(items))
            }
    }

    func isFavoriteItem(
        uid: String,
        productId: String,
        completion: @escaping (Bool) -> Void
    ){
        favoritesCollection(uid)
            .document(productId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error checking favorite item", error)
                    completion(false)
                    return
                }
                completion(snapshot?.exists == true)
            }
    }
    
    //MARK: History
    struct HistoryItem {
        let id: String
        let productId: String
        let name: String
        let category: String
        let safetyScore: Int
        let searchedAt: Date
        let ingredientInfoJSON: String
        let safetyJSON: String
    }

    func addHistoryItem(
        uid: String,
        productId: String,
        name: String,
        category: String,
        safetyScore: Int,
        ingredientInfoJSON: String,
        safetyJSON: String,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "productId": productId,
            "name": name,
            "category": category,
            "safetyScore": safetyScore,
            "ingredientInfoJSON": ingredientInfoJSON,
            "safetyJSON": safetyJSON,
            "searchedAt": FieldValue.serverTimestamp()
        ]

        historyCollection(uid)
            .document(productId)
            .setData(data, merge: true, completion: completion)
    }


    func fetchHistoryItems(
        forUserID uid: String,
        completion: @escaping (Result<[HistoryItem], Error>) -> Void
    ) {
        historyCollection(uid)
            .order(by: "searchedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let allItems: [HistoryItem] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    
                    guard
                        let productId = data["productId"] as? String,
                        let name = data["name"] as? String,
                        let category = data["category"] as? String,
                        let safetyScore = data["safetyScore"] as? Int,
                        let ts = data["searchedAt"] as? Timestamp
                    else {
                        return nil
                    }
                    
                    let ingredientInfoJSON = data["ingredientInfoJSON"] as? String ?? "{}"
                    let safetyJSON = data["safetyJSON"] as? String ?? "{}"
                    
                    return HistoryItem(
                        id: doc.documentID,
                        productId: productId,
                        name: name,
                        category: category,
                        safetyScore: safetyScore,
                        searchedAt: ts.dateValue(),
                        ingredientInfoJSON: ingredientInfoJSON,
                        safetyJSON: safetyJSON
                    )
                } ?? []
                
                // Ensure only latest per productId
                let latestDict = allItems.reduce(into: [String: HistoryItem]()) { dict, item in
                    if let existing = dict[item.productId] {
                        if item.searchedAt > existing.searchedAt {
                            dict[item.productId] = item
                        }
                    } else {
                        dict[item.productId] = item
                    }
                }
                
                let finalList = latestDict.values.sorted { $0.searchedAt > $1.searchedAt }
                completion(.success(finalList))
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
    
    func updateUserHealthData(uid: String,
                              allergies: [String],
                              medications: [String],
                              medicalConditions: [String],
                              completion: @escaping (Error?) -> Void)
    {
        let data: [String: Any] = [
            "allergies": allergies,
            "medications": medications,
            "medicalConditions": medicalConditions
        ]

        db.collection("users").document(uid).updateData(data) { error in
            completion(error)
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
    
    // MARK: - DELETE ALL HISTORY
    func deleteAllHistory(uid: String, completion: @escaping (Error?) -> Void) {
        db.collection("history")
            .document(uid)
            .collection("items")
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(error)
                    return
                }

                guard let docs = snapshot?.documents else {
                    completion(nil)
                    return
                }

                let batch = self.db.batch()

                for doc in docs {
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { batchError in
                    completion(batchError)
                }
            }
    }


}
