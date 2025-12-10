import UIKit
import FirebaseAuth

class SearchViewController: UIViewController, UITextFieldDelegate {

    private let searchView = SearchView(frame: .zero)

    // Full history loaded OR newly scanned
    private var allProducts: [HistoryProduct] = []

    // Filtered results
    private var filteredProducts: [HistoryProduct] = []
    
    private let aiStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.alpha = 0          // hidden initially
        return label
    }()


    // Struct used locally for UI
    struct HistoryProduct {
        let name: String
        let safetyScore: Int
        let pillColor: UIColor
        let ingredientInfoJSON: String
        let safetyJSON: String
    }

    override func loadView() {
        view = searchView
        searchView.delegate = self

        // Live search
        searchView.searchFieldView.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
        searchView.searchFieldView.delegate = self
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBlue
        title = "Search"

        searchView.productsTableView.dataSource = self
        searchView.productsTableView.delegate = self
        
        view.addSubview(aiStatusLabel)
        aiStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            aiStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            aiStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aiStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aiStatusLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let uid = Auth.auth().currentUser?.uid {
            FirebaseService.shared.fetchUserProfile(uid: uid) { result in
                if case .success(let profile) = result {
                    UserProfileManager.shared.updateCurrentUser(profile)
                }
            }
        }

        loadHistoryFromFirestore()
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !query.isEmpty {
            performSearch(query: query)
            view.endEditing(true)  // dismiss keyboard
        }

        return true
    }

    
    private func pillColor(for score: Int) -> UIColor {
        if score < 20 { return .systemRed }
        if score < 50 { return .systemYellow }
        return .systemGreen
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadHistoryFromFirestore()
//    }
    
    // In SearchViewController.swift

    func performSearch(query: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Step 1 — Search History first
        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let err):
                print("History fetch error:", err)
                self.showAIStatus("Searching with AI…")
                self.fetchFromLLM(query: query)   // fallback to LLM
            case .success(let history):
                if let match = history.first(where: { $0.name.lowercased() == query.lowercased() }) {

                    // FOUND IN HISTORY — open immediately
                    DispatchQueue.main.async {
                        let vc = ProductInfoViewController(
                            name: match.name,
                            safetyScore: match.safetyScore,
                            pillColor: self.colorFor(score: match.safetyScore),
                            ingredientInfoJSON: match.ingredientInfoJSON,
                            safetyJSON: match.safetyJSON
                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    // NOT FOUND — query LLM
                    self.fetchFromLLM(query: query)
                }
            }
        }
    }

}

//
// MARK: - Firestore History
//
extension SearchViewController {

    private func loadHistoryFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { result in
            switch result {
            case .success(let items):

                // Convert Firestore → UI list
                self.allProducts = items.map { entry in
                    HistoryProduct(
                        name: entry.name,
                        safetyScore: entry.safetyScore,
                        pillColor: self.pillColor(for: entry.safetyScore),
                        ingredientInfoJSON: entry.ingredientInfoJSON,
                        safetyJSON: entry.safetyJSON
                    )
                }

                self.filteredProducts = self.allProducts

                DispatchQueue.main.async {
                    self.searchView.productsTableView.reloadData()
                }

            case .failure(let error):
                print("History fetch error:", error)
            }
        }
    }
}

//
// MARK: - Live Search
//
extension SearchViewController {

    @objc private func searchTextChanged() {
        let query = searchView.searchFieldView.text?.lowercased() ?? ""

        if query.isEmpty {
            filteredProducts = allProducts
        } else {
            filteredProducts = allProducts.filter {
                $0.name.lowercased().contains(query)
            }
        }

        searchView.productsTableView.reloadData()
    }
}

//
// MARK: - ScanDelegate (FINAL VERSION)
//
extension SearchViewController: ScanDelegate {

    func didScanProduct(
        name: String,
        safetyScore: Int,
        pillColor: UIColor,
        ingredientInfoJSON: String,
        safetyJSON: String
    ) {
        // 1️⃣ Create product for display
        let newItem = HistoryProduct(
            name: name,
            safetyScore: safetyScore,
            pillColor: pillColor,
            ingredientInfoJSON: ingredientInfoJSON,
            safetyJSON: safetyJSON
        )

        // 2️⃣ Insert at top of history list
        allProducts.insert(newItem, at: 0)
        filteredProducts = allProducts

        // 3️⃣ Refresh SearchView instantly
        DispatchQueue.main.async {
            self.searchView.productsTableView.reloadData()
        }

        // Firestore save already happens inside ImageCaptureViewController
    }
}

//
// MARK: - TableView
//
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else { return UITableViewCell() }

        let product = filteredProducts[indexPath.row]

        cell.configure(
            name: product.name,
            safetyIndex: "\(product.safetyScore)"
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = filteredProducts[indexPath.row]

        //  OPEN FULL DETAILS WITH REAL JSON DATA
        let vc = ProductInfoViewController(
            name: item.name,
            safetyScore: item.safetyScore,
            pillColor: item.pillColor,
            ingredientInfoJSON: item.ingredientInfoJSON,
            safetyJSON: item.safetyJSON
        )

        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.backgroundColor = .clear
    }
    
    
}

//
// MARK: - Helpers
//


//
// MARK: - SearchViewDelegate
//
extension SearchViewController: SearchViewDelegate {

    func didTapScanButton() {
        let scanVC = ImageCaptureViewController()
        scanVC.scanDelegate = self
        navigationController?.pushViewController(scanVC, animated: true)
    }
}

extension SearchViewController {

    func fetchFromLLM(query: String) {
        Task {
            do {
                // 1. Category
                let catPrompt = LLMPrompts.classifyCategory(name: query, description: "")
                let categoryJSON = try await GroqService.shared.run(prompt: catPrompt)
                let category = extractCategory(from: categoryJSON)

                // 2. Ingredient extraction
                let ingPrompt = LLMPrompts.extractIngredients(raw: query)
                let ingJSON = try await GroqService.shared.run(prompt: ingPrompt)
                let ingredients = extractIngredients(from: ingJSON)

                // 3. Safety check
                let user = UserProfileManager.shared.currentUser
                let safetyPrompt = LLMPrompts.safetyCheck(
                    ingredients: ingredients,
                    allergies: user?.allergies ?? [],
                    conditions: user?.medicalConditions ?? [],
                    meds: user?.medications ?? []
                )
                let safetyJSON = try await GroqService.shared.run(prompt: safetyPrompt)
                let ingModels = ingredients.map { Ingredient(name: $0, safety: .safe, infoText: "") }
                let safetyScore = SafetyScoring.compute(ingredients: ingModels, user: user)



                // 4. Ingredient info
                let infoPrompt = LLMPrompts.ingredientInfo(ingredients: ingredients)
                let infoJSON = try await GroqService.shared.run(prompt: infoPrompt)

                // 5. Open product info page
                DispatchQueue.main.async {
                    self.hideAIStatus()
                    let vc = ProductInfoViewController(
                        name: query,
                        safetyScore: safetyScore,
                        pillColor: self.colorFor(score: safetyScore),
                        ingredientInfoJSON: infoJSON,
                        safetyJSON: safetyJSON
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                // 6. Save to history
                if let uid = Auth.auth().currentUser?.uid {
                    FirebaseService.shared.addHistoryItem(
                        uid: uid,
                        productId: query,
                        name: query,
                        category: category,
                        safetyScore: safetyScore,
                        ingredientInfoJSON: infoJSON,
                        safetyJSON: safetyJSON
                    ) { err in
                        if let err = err { print("History save error:", err) }
                    }
                }

            } catch {
                print("❌ LLM fetch failed:", error)
            }
        }
    }
}

// MARK: - JSON extractors
extension SearchViewController {
    func extractCategory(from json: String) -> String {
        (json.toJSONDict()?["category"] as? String) ?? "unknown"
    }

    func extractIngredients(from json: String) -> [String] {
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

extension SearchViewController {

    func showAIStatus(_ message: String) {
        aiStatusLabel.text = message
        UIView.animate(withDuration: 0.25) {
            self.aiStatusLabel.alpha = 1
        }
    }

    func hideAIStatus() {
        UIView.animate(withDuration: 0.25) {
            self.aiStatusLabel.alpha = 0
        }
    }
}

