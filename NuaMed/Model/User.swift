import Foundation
import FirebaseFirestore

struct User {
    let uid: String
    let username: String
    let email: String
    var name: String?
    var gender: String?
    var dob: Date?
    var age: Int?
    var allergies: [String]
    var medications: [String]
    var medicalConditions: [String]
    var profileSetup: Bool
    var profileImageBase64: String?

    init(uid: String,
         username: String,
         email: String,
         name: String? = nil,
         gender: String? = nil,
         dob: Date? = nil,
         age: Int? = nil,
         allergies: [String] = [],
         medications: [String] = [],
         medicalConditions: [String] = [],
         profileSetup: Bool = false,
         profileImageBase64: String? = nil) {
        self.uid = uid
        self.username = username
        self.email = email
        self.name = name
        self.gender = gender
        self.dob = dob
        self.age = age
        self.allergies = allergies
        self.medications = medications
        self.medicalConditions = medicalConditions
        self.profileSetup = profileSetup
        self.profileImageBase64 = profileImageBase64
    }

    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "username": username,
            "email": email,
            "name": name as Any,
            "gender": gender as Any,
            "dob": dob as Any, // Store as Date directly
            "age": age as Any,
            "allergies": allergies,
            "medications": medications,
            "medicalConditions": medicalConditions,
            "profileSetup": profileSetup,
            "profileImageBase64": profileImageBase64 as Any
        ]
    }

    init(from dict: [String: Any]) {
        self.uid = dict["uid"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.name = dict["name"] as? String
        self.gender = dict["gender"] as? String
        
        // Firestore stores dates as Timestamp
        if let timestamp = dict["dob"] as? Timestamp {
            self.dob = timestamp.dateValue()
        } else {
            self.dob = nil
        }

        self.age = dict["age"] as? Int
        self.allergies = dict["allergies"] as? [String] ?? []
        self.medications = dict["medications"] as? [String] ?? []
        self.medicalConditions = dict["medicalConditions"] as? [String] ?? []
        self.profileSetup = dict["profileSetup"] as? Bool ?? false
        self.profileImageBase64 = dict["profileImageBase64"] as? String
    }
}
