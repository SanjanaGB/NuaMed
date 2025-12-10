import Foundation
import FirebaseAuth

class UserProfileManager {
    static let shared = UserProfileManager()
    private init() {}

    // Stores the entire user object
    private(set) var currentUser: User?

    // MARK: - Load profile after login
    func loadUserProfile(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("⚠️ No logged-in user found")
            completion()
            return
        }

        FirebaseService.shared.fetchUserProfile(uid: uid) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                print("✅ UserProfileManager loaded user:", user.username)

            case .failure(let error):
                print("❌ Failed to load user profile:", error)
            }

            completion()
        }
    }

    func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
    }

    // MARK: - Update user allergies, medications, conditions
    func updateHealthData(allergies: [String],
                          medications: [String],
                          medicalConditions: [String],
                          completion: @escaping (Error?) -> Void)
    {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }

        FirebaseService.shared.updateUserHealthData(
            uid: uid,
            allergies: allergies,
            medications: medications,
            medicalConditions: medicalConditions
        ) { error in

            if error == nil {
                // Update memory copy
                if var user = self.currentUser {
                    user.allergies = allergies
                    user.medications = medications
                    user.medicalConditions = medicalConditions
                    self.currentUser = user
                }
            }

            completion(error)
        }
    }
}
