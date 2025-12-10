import UIKit
import FirebaseAuth

class ItemScanningController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
    }

    // MARK: - Main Processing Pipeline
    func processScannedProduct(name: String,
                               description: String,
                               rawIngredients: String)
    {
        Task {
            do {
                // 1️⃣ Category (GROQ)
                let catPrompt = LLMPrompts.classifyCategory(name: name, description: description)
                let categoryJSON = try await GroqService.shared.run(prompt: catPrompt)
                let category = extractCategory(from: categoryJSON)

                // 2️⃣ Ingredients (GROQ)
                let ingPrompt = LLMPrompts.extractIngredients(raw: rawIngredients)
                let ingJSON = try await GroqService.shared.run(prompt: ingPrompt)
                let ingredients = extractIngredients(from: ingJSON)   // returns [String]

                // 3️⃣ User profile
                let user = UserProfileManager.shared.currentUser

                // 4️⃣ Safety
                let safetyPrompt = LLMPrompts.safetyCheck(
                    ingredients: ingredients,
                    allergies: user?.allergies ?? [],
                    conditions: user?.medicalConditions ?? [],
                    meds: user?.medications ?? []
                )
                let safetyJSON = try await GroqService.shared.run(prompt: safetyPrompt)
                let safetyScore = extractSafetyScore(from: safetyJSON)

                // 5️⃣ Ingredient info
                let infoPrompt = LLMPrompts.ingredientInfo(ingredients: ingredients)
                let infoJSON = try await GroqService.shared.run(prompt: infoPrompt)

                // 6️⃣ Push Product Info Screen
                DispatchQueue.main.async {
                    let vc = ProductInfoViewController(
                        name: name,
                        safetyScore: safetyScore,
                        pillColor: self.colorFor(score: safetyScore),
                        ingredientInfoJSON: infoJSON,
                        safetyJSON: safetyJSON
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                // 7️⃣ Save to history
                // 7️⃣ Save to history
                if let uid = Auth.auth().currentUser?.uid {
                    FirebaseService.shared.addHistoryItem(
                        uid: uid,
                        productId: name,
                        name: name,
                        category: category,
                        safetyScore: safetyScore,
                        ingredientInfoJSON: infoJSON,   // ← include this
                        safetyJSON: safetyJSON          // ← include this
                    ) { error in
                        if let error = error { print("History save error:", error) }
                    }
                }


            } catch {
                print("❌ LLM error:", error)
            }
        }
    }
}

// MARK: - JSON Helpers

extension ItemScanningController {

    func extractCategory(from json: String) -> String {
        (json.toJSONDict()?["category"] as? String) ?? "unknown"
    }

    func extractIngredients(from json: String) -> [String] {
        // Groq returns array of objects: [{name:"", safetyLevel:"", info:""}]
        guard
            let dict = json.toJSONDict(),
            let items = dict["ingredients"] as? [[String: Any]]
        else { return [] }

        return items.compactMap { $0["name"] as? String }
    }

    func extractSafetyScore(from json: String) -> Int {
        (json.toJSONDict()?["overallSafetyScore"] as? Int) ?? 50
    }

    func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
}

// MARK: - Safe JSON Parsing Extension
