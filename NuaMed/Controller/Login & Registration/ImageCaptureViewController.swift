import UIKit
import AVFoundation
import Vision
import FirebaseAuth

// MARK: - Delegate sent back to Search screen


class ImageCaptureViewController: UIViewController {

    private let captureView = ImageCaptureView()
    private var imagePicker: UIImagePickerController?
    
    weak var scanDelegate: ScanDelegate?   // <-- FIX ADDED

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

// MARK: - Image Picker Actions
extension ImageCaptureViewController:
    ImageCaptureViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    func didTapChooseImage() {
        let alert = UIAlertController(
            title: "Upload Image",
            message: "Choose an option",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Capture Image", style: .default) { _ in
            self.openCamera()
        })
        alert.addAction(UIAlertAction(title: "Select from Gallery", style: .default) { _ in
            self.openGallery()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Unavailable",
                      message: "Choose from gallery instead.")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
        imagePicker = picker
    }

    private func openGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        imagePicker = picker
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        if let img = info[.originalImage] as? UIImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.captureView.setCapturedImage(img)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func didTapSubmit(image: UIImage?) {
        guard let img = image else {
            showAlert(title: "No Image",
                      message: "Please upload or capture an image first.")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.detectBarcode(in: img)
        }
    }
}

// MARK: - Barcode Detection (Vision)
extension ImageCaptureViewController {

    func detectBarcode(in image: UIImage) {
        guard let cgImage = image.cgImage else {
            showAlert(title: "Invalid Image", message: "Could not process image.")
            return
        }

        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("Barcode detection error:", error)
                self.showAlert(title: "Error", message: "No barcode detected.")
                return
            }

            guard let result = request.results?.first as? VNBarcodeObservation,
                  let code = result.payloadStringValue else {
                self.showAlert(title: "No Barcode", message: "No barcode found.")
                return
            }

            print("BARCODE DETECTED:", code)
            self.handleScannedBarcode(code)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - MAIN PIPELINE
extension ImageCaptureViewController {

    func handleScannedBarcode(_ code: String) {
        Task {
            do {
                // 1️⃣ Lookup product
                let result = try await BarcodeLookupService.shared.lookup(upc: code)

                // 2️⃣ Ingredient extraction fallback
                let rawIngredients = result.ingredients?.isEmpty == false
                    ? result.ingredients!
                    : "INGREDIENTS_FROM_LLM"

                let finalIngredients = try await extractIngredientsIfNeeded(
                    raw: rawIngredients,
                    description: result.description
                )

                // 3️⃣ Safety + ingredient Groq analysis
                let safety = try await runSafetyPipeline(
                    productName: result.name,
                    rawIngredients: finalIngredients
                )

                // 4️⃣ Notify Search screen that a product was scanned (FIX)
                scanDelegate?.didScanProduct(
                    name: result.name,
                    safetyScore: safety.score,
                    pillColor: colorFor(score: safety.score),
                    ingredientInfoJSON: safety.ingredientsJSON,
                    safetyJSON: safety.safetyJSON
                )


                // 5️⃣ Open ProductInfo page
                let vc = ProductInfoViewController(
                    name: result.name,
                    safetyScore: safety.score,
                    pillColor: colorFor(score: safety.score),
                    ingredientInfoJSON: safety.ingredientsJSON,
                    safetyJSON: safety.safetyJSON
                )

                self.navigationController?.pushViewController(vc, animated: true)

                // 6️⃣ Save history to Firestore
                if let uid = Auth.auth().currentUser?.uid {
                    FirebaseService.shared.addHistoryItem(
                        uid: uid,
                        productId: code,
                        name: result.name,
                        category: safety.category,
                        safetyScore: safety.score,
                        ingredientInfoJSON: safety.ingredientsJSON,
                        safetyJSON: safety.safetyJSON
                    )
 { error in
                        if let error = error { print("History error:", error) }
                    }
                }

            } catch {
                print("Processing error:", error)
                showAlert(title: "Error", message: "Product could not be identified.")
            }
        }
    }

    func extractIngredientsIfNeeded(raw: String, description: String) async throws -> String {
        if raw != "INGREDIENTS_FROM_LLM" { return raw }
        let prompt = LLMPrompts.extractIngredients(raw: description)
        return try await GroqService.shared.run(prompt: prompt)
    }

    struct SafetyPipelineResult {
        let score: Int
        let category: String
        let ingredientsJSON: String
        let safetyJSON: String
    }

    func runSafetyPipeline(productName: String, rawIngredients: String) async throws -> SafetyPipelineResult {

        let user = UserProfileManager.shared.currentUser

        let ingredientsArray = rawIngredients
            .components(separatedBy: [",", ".", ";", "\n"])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Category
        let catPrompt = LLMPrompts.classifyCategory(name: productName, description: rawIngredients)
        let categoryJSON = try await GroqService.shared.run(prompt: catPrompt)
        let category = categoryJSON.toJSONDict()?["category"] as? String ?? "unknown"

        // Ingredient info
        let infoPrompt = LLMPrompts.ingredientInfo(ingredients: ingredientsArray)
        let ingredientJSON = try await GroqService.shared.run(prompt: infoPrompt)

        // Safety score
        let safetyPrompt = LLMPrompts.safetyCheck(
            ingredients: ingredientsArray,
            allergies: user?.allergies ?? [],
            conditions: user?.medicalConditions ?? [],
            meds: user?.medications ?? []
        )

        let safetyJSON = try await GroqService.shared.run(prompt: safetyPrompt)
        let score = safetyJSON.toJSONDict()?["overallSafetyScore"] as? Int ?? 50

        return SafetyPipelineResult(
            score: score,
            category: category,
            ingredientsJSON: ingredientJSON,
            safetyJSON: safetyJSON
        )
    }

    func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
}
