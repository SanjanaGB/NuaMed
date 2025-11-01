import UIKit
import FirebaseAuth

class ProfileSetupViewController: UIViewController, UITextFieldDelegate {

    private let profileView = ProfileSetupView()
    private var isProfileImageSet: Bool = false


    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Profile Setup") { [weak self] in
            guard let self = self else { return }
            let imageCapture = ImageCaptureViewController()
            self.navigationController?.setViewControllers([imageCapture], animated: true)
        }

        profileView.delegate = self
        profileView.ageField.delegate = self
        loadUserProfile()
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == profileView.ageField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }


    private func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchUserProfile(uid: uid) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    print("Failed to fetch profile: \(err)")
                case .success(let user):
                    self.profileView.nameField.text = user.name
                    self.profileView.genderField.text = user.gender
                    if let age = user.age { self.profileView.ageField.text = "\(age)" }

                    self.profileView.allergies = user.allergies
                    self.profileView.medicalConditions = user.medicalConditions
                    self.profileView.medications = user.medications
                    

                    FirebaseService.shared.fetchProfileImage(uid: uid) { imageResult in
                        DispatchQueue.main.async {
                            switch imageResult {
                            case .success(let image):
                                print("DEBUG: Fetched image from Firebase is", image == nil ? "nil" : "valid")
                                if let image = image {
                                    self.profileView.profileImageView.image = image
                                    self.profileView.profileImageView.contentMode = .scaleAspectFill
                                } else {
                                    self.setPlaceholderImage(for: self.profileView.profileImageView)
                                }
                            case .failure(_):
                                self.setPlaceholderImage(for: self.profileView.profileImageView)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ProfileSetupViewController: ProfileSetupViewDelegate {

    func didTapOpenList(for type: String) {
        let items: [String]
        switch type {
        case "Allergies": items = profileView.allergies
        case "Medical Conditions": items = profileView.medicalConditions
        case "Medications": items = profileView.medications
        default: return
        }

        let popup = ListPopupViewController(title: "Edit \(type)", items: items, type: type)
        popup.delegate = self
        let nav = UINavigationController(rootViewController: popup)
        present(nav, animated: true)
    }

    func didSaveProfile(
        name: String,
        gender: String,
        age: Int?,
        allergies: [String],
        medicalConditions: [String],
        medications: [String],
        profileImage: UIImage?
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Not signed in", message: "Please login again.")
            return
        }
        
        FirebaseService.shared.fetchUserProfile(uid: uid) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.showAlert(title: "Error", message: err.localizedDescription)
                case .success(var user):
                    user.name = name
                    user.gender = gender
                    user.age = age
                    user.allergies = allergies
                    user.medicalConditions = medicalConditions
                    user.medications = medications
                    user.profileSetup = true
                    
                    func saveUser() {
                        FirebaseService.shared.saveProfile(uid: uid, profile: user) { err2 in
                            self.handleProfileSaveResult(err: err2)
                        }
                    }
                    
                    if let image = profileImage, self.isProfileImageSet {
                        FirebaseService.shared.saveProfileImage(uid: uid, image: image) { err in
                            DispatchQueue.main.async {
                                if let err = err {
                                    self.showAlert(title: "Error", message: err.localizedDescription)
                                    return
                                }
                                if let data = image.jpegData(compressionQuality: 0.5) {
                                    user.profileImageBase64 = data.base64EncodedString()
                                }
                                saveUser()
                            }
                        }
                    } else {
                        saveUser()
                    }
                }
            }
        }
    }


    func didRequestChangeCredentials() {
        promptForCredentialChange()
    }

    func didTapBack() {
        let imageCapture = ImageCaptureViewController()
        navigationController?.setViewControllers([imageCapture], animated: true)
    }

    func didSkipProfile() {
        let imageCapture = ImageCaptureViewController()
        navigationController?.setViewControllers([imageCapture], animated: true)
    }


    private func handleProfileSaveResult(err: Error?) {
        DispatchQueue.main.async {
            if let err = err {
                self.showAlert(title: "Error", message: err.localizedDescription)
            } else {
                let alert = UIAlertController(title: "Success", message: "Profile saved successfully.", preferredStyle: .alert)
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        alert.dismiss(animated: true)
                    }
                }
            }
        }
    }


    private func promptForCredentialChange() {
        let alert = UIAlertController(title: "Change Credentials", message: "Choose what to change", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Change Email", style: .default) { _ in self.askCurrentPasswordAndNewEmail() })
        alert.addAction(UIAlertAction(title: "Change Password", style: .default) { _ in self.askCurrentPasswordAndNewPassword() })
        alert.addAction(UIAlertAction(title: "Change Username", style: .default) { _ in self.askNewUsername() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func askNewUsername() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let a = UIAlertController(title: "New Username", message: "Enter new username", preferredStyle: .alert)
        a.addTextField { $0.placeholder = "New username"; $0.autocapitalizationType = .none }
        
        a.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let new = a.textFields?.first?.text, !new.isEmpty else { return }
            FirebaseService.shared.fetchUserProfile(uid: uid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.showAlert(title: "Error", message: "Couldn't fetch profile")
                    case .success(let profile):
                        let currentUsername = profile.username ?? ""
                        
                        if new == currentUsername {
                            self.showAlert(title: "Same Username", message: "You entered your current username. Please choose a different one.")
                            return
                        }
                        FirebaseService.shared.isUsernameTaken(new) { taken in
                            DispatchQueue.main.async {
                                if taken {
                                    self.showAlert(title: "Taken", message: "Username already taken")
                                    return
                                }

                                FirebaseService.shared.updateUsername(uid: uid, newUsername: new) { err in
                                    if let err = err {
                                        self.showAlert(title: "Error", message: err.localizedDescription)
                                    } else {
                                        self.showAlert(title: "Saved", message: "Username updated")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })

        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(a, animated: true)
    }


    private func askCurrentPasswordAndNewEmail() {
        let a = UIAlertController(title: "Change Email", message: "Enter current password and new email", preferredStyle: .alert)
        a.addTextField { $0.placeholder = "Current password"; $0.isSecureTextEntry = true }
        a.addTextField { $0.placeholder = "New email"; $0.keyboardType = .emailAddress }
        a.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let curr = a.textFields?[0].text ?? ""
            let newEmail = a.textFields?[1].text ?? ""
            FirebaseService.shared.reauthenticateAndChangeEmail(currentPassword: curr, newEmail: newEmail) { err in
                DispatchQueue.main.async {
                    if let err = err { self.showAlert(title: "Error", message: err.localizedDescription); return }
                    self.showAlert(title: "Saved", message: "Email updated")
                }
            }
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(a, animated: true)
    }

    private func askCurrentPasswordAndNewPassword() {
        let a = UIAlertController(title: "Change Password", message: "Enter current password and new password", preferredStyle: .alert)
        a.addTextField { $0.placeholder = "Current password"; $0.isSecureTextEntry = true }
        a.addTextField { $0.placeholder = "New password"; $0.isSecureTextEntry = true }
        a.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let curr = a.textFields?[0].text ?? ""
            let newPass = a.textFields?[1].text ?? ""
            FirebaseService.shared.reauthenticateAndChangePassword(currentPassword: curr, newPassword: newPass) { err in
                DispatchQueue.main.async {
                    if let err = err { self.showAlert(title: "Error", message: err.localizedDescription); return }
                    self.showAlert(title: "Saved", message: "Password updated")
                }
            }
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(a, animated: true)
    }
}

extension ProfileSetupViewController: ListPopupDelegate {
    func didUpdateList(_ items: [String], forType type: String) {
        switch type {
        case "Allergies":
            profileView.allergies = items
        case "Medical Conditions":
            profileView.medicalConditions = items
        case "Medications":
            profileView.medications = items
        default: break
        }
    }
}

extension ProfileSetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func didTapChooseImage() {
        let alert = UIAlertController(title: "Profile Image", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Capture Image", style: .default) { _ in
            self.openCamera()
        })
        
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default) { _ in
            self.openGallery()
        })
        
        alert.addAction(UIAlertAction(title: "Remove Image", style: .destructive) { _ in
            self.removeProfileImage()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func removeProfileImage() {
        self.setPlaceholderImage(for: profileView.profileImageView)
        
        isProfileImageSet = false
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FirebaseService.shared.saveProfileImage(uid: uid, image: nil) { err in
            if let err = err {
                self.showAlert(title: "Error", message: err.localizedDescription)
            } else {
                FirebaseService.shared.fetchUserProfile(uid: uid) { result in
                    if case .success(var profile) = result {
                        profile.profileImageBase64 = nil
                        FirebaseService.shared.saveProfile(uid: uid, profile: profile) { _ in }
                    }
                }
            }
        }
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            profileView.setCapturedImage(img)
            isProfileImageSet = true  // user set an image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func setPlaceholderImage(for imageView: UIImageView, backgroundColor: UIColor = UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0)) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        imageView.backgroundColor = backgroundColor
        

        let personColor = UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: imageView.frame.size.width * 0.6, weight: .regular)
        
        let placeholder = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?
            .withTintColor(personColor, renderingMode: .alwaysOriginal)
        
        imageView.image = placeholder
        imageView.contentMode = .scaleAspectFit
    }

}
