import UIKit
import AVFoundation
import FirebaseAuth

class ImageCaptureViewController: UIViewController {

    private let captureView = ImageCaptureView()
    private var imagePicker: UIImagePickerController?

    override func loadView() { view = captureView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Upload Image") {
            let searchVC = SearchViewController()
            self.navigationController?.setViewControllers([searchVC], animated: true)
        }
        captureView.delegate = self
    }

}

extension ImageCaptureViewController: ImageCaptureViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func didTapChooseImage() {
        let alert = UIAlertController(title: "Upload Image", message: "Choose an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Capture Image", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            present(picker, animated: true)
            imagePicker = picker
        } else {
            // Simulator fallback: just open photo library or show alert
            showAlert(title: "Camera not available", message: "Simulator has no camera. Please select from gallery.") {
                self.openGallery()
            }
        }
    }

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        imagePicker = picker
    }

    func didTapSubmit(image: UIImage?) {
        showAlert(title: "Submit", message: "Submit pressed. No operation implemented yet.")
    }

//    func didTapLogout() {
//        do {
//            try Auth.auth().signOut()
//            let loginVC = LoginViewController()
//            navigationController?.setViewControllers([loginVC], animated: true)
//        } catch {
//            showAlert(title: "Error", message: "Failed to logout: \(error.localizedDescription)")
//        }
//    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            captureView.setCapturedImage(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
