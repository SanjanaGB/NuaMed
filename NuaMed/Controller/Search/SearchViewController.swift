import UIKit
import FirebaseAuth

class SearchViewController: UIViewController, UITextFieldDelegate {

    private let searchView = SearchView(frame: .zero)

    // Full stored user history
    private var allProducts: [HistoryProduct] = []

    // Filtered list for display
    private var filteredProducts: [HistoryProduct] = []
    
    // AI Status Indicator
    private let aiStatusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.alpha = 0
        return label
    }()

    // Model for UI table rows
    struct HistoryProduct {
        let name: String
        let safetyScore: Int
        let pillColor: UIColor
        let ingredientInfoJSON: String
        let safetyJSON: String
    }

    // MARK: - VIEW LOAD
    override func loadView() {
        view = searchView
        searchView.delegate = self

        searchView.searchFieldView.delegate = self
        searchView.searchFieldView.addTarget(
            self,
            action: #selector(searchTextChanged),
            for: .editingChanged
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        title = "Search"

        searchView.productsTableView.dataSource = self
        searchView.productsTableView.delegate = self
        
        setupAIStatusLabel()
        setupDeleteHistoryButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reload user profile
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseService.shared.fetchUserProfile(uid: uid) { result in
                if case .success(let profile) = result {
                    UserProfileManager.shared.updateCurrentUser(profile)
                }
            }
        }

        loadHistoryFromFirestore()
    }


    // MARK: - UI BUTTONS
    private func setupDeleteHistoryButton() {
        let button = UIBarButtonItem(
            title: "Clear History",
            style: .plain,
            target: self,
            action: #selector(clearHistoryTapped)
        )
        navigationItem.rightBarButtonItem = button
    }

    @objc private func clearHistoryTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let alert = UIAlertController(
            title: "Delete All History?",
            message: "This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            FirebaseService.shared.deleteAllHistory(uid: uid) { error in
                if error == nil {
                    self.allProducts.removeAll()
                    self.filteredProducts.removeAll()
                    DispatchQueue.main.async {
                        self.searchView.productsTableView.reloadData()
                    }
                } else {
                    print("Delete error:", error!)
                }
            }
        })

        present(alert, animated: true)
    }

    // MARK: - STATUS LABEL
    private func setupAIStatusLabel() {
        view.addSubview(aiStatusLabel)
        aiStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            aiStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            aiStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aiStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aiStatusLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func showAIStatus(_ text: String) {
        aiStatusLabel.text = text
        UIView.animate(withDuration: 0.25) { self.aiStatusLabel.alpha = 1 }
    }

    func hideAIStatus() {
        UIView.animate(withDuration: 0.25) { self.aiStatusLabel.alpha = 0 }
    }


    // MARK: - RETURN KEY SEARCH
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !query.isEmpty { performSearch(query: query) }
        view.endEditing(true)
        return true
    }


    // MARK: - SAFETY SCORE COLOR
    private func pillColor(for score: Int) -> UIColor {
        if score < 20 { return .systemRed }
        if score < 50 { return .systemYellow }
        return .systemGreen
    }


    // MARK: - FETCH HISTORY
    private func loadHistoryFromFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { result in
            switch result {
            case .failure(let err):
                print("History fetch error:", err)

            case .success(let items):
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
            }
        }
    }


    // MARK: - LIVE FILTERING
    @objc private func searchTextChanged() {
        let q = searchView.searchFieldView.text?.lowercased() ?? ""

        filteredProducts =
            q.isEmpty
            ? allProducts
            : allProducts.filter { $0.name.lowercased().contains(q) }

        searchView.productsTableView.reloadData()
    }


    // MARK: - MAIN SEARCH
    func performSearch(query: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { [weak self] result in
            guard let self = self else { return }

            switch result {

            case .failure(_):
                self.fetchFromLLM(query: query)

            case .success(let history):
                if let match = history.first(where: { $0.name.lowercased() == query.lowercased() }) {

                    let uiItem = HistoryProduct(
                        name: match.name,
                        safetyScore: match.safetyScore,
                        pillColor: self.pillColor(for: match.safetyScore),
                        ingredientInfoJSON: match.ingredientInfoJSON,
                        safetyJSON: match.safetyJSON
                    )

                    self.openProduct(uiItem)
                    
                } else {
                    self.fetchFromLLM(query: query)
                }

            }
        }
    }


    // MARK: - OPEN EXISTING PRODUCT FROM HISTORY
    private func openProduct(_ item: HistoryProduct) {
        DispatchQueue.main.async {
            let vc = ProductInfoViewController(
                name: item.name,
                safetyScore: item.safetyScore,
                pillColor: item.pillColor,
                ingredientInfoJSON: item.ingredientInfoJSON,
                safetyJSON: item.safetyJSON
            )
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }



    // MARK: - LLM WORKFLOW
    func fetchFromLLM(query: String) {
        Task {
            do {
                showAIStatus("Analyzing with AI…")

                let user = UserProfileManager.shared.currentUser

                // 1 — Category
                let catPrompt = LLMPrompts.classifyCategory(name: query, description: "")
                let catJSON = try await GroqService.shared.run(prompt: catPrompt)
                let category = extractCategory(from: catJSON)

                // 2 — Ingredients
                let ingPrompt = LLMPrompts.extractIngredients(raw: query)
                let ingJSON = try await GroqService.shared.run(prompt: ingPrompt)
                let ingredientNames = extractIngredients(from: ingJSON)

                // 3 — Safety Check
                let safetyPrompt = LLMPrompts.safetyCheck(
                    ingredients: ingredientNames,
                    allergies: user?.allergies ?? [],
                    conditions: user?.medicalConditions ?? [],
                    meds: user?.medications ?? []
                )
                let safetyJSON = try await GroqService.shared.run(prompt: safetyPrompt)

                // 4 — Ingredient Info
                let infoPrompt = LLMPrompts.ingredientInfo(ingredients: ingredientNames)
                let infoJSON = try await GroqService.shared.run(prompt: infoPrompt)

                // 5 — Safety Score
                let ingModels = ingredientNames.map {
                    Ingredient(name: $0, safety: .safe, infoText: "")
                }
                let safetyScore = SafetyScoring.compute(ingredients: ingModels, user: user)

                hideAIStatus()

                // Open product details
                DispatchQueue.main.async {
                    let vc = ProductInfoViewController(
                        name: query,
                        safetyScore: safetyScore,
                        pillColor: self.pillColor(for: safetyScore),
                        ingredientInfoJSON: infoJSON,
                        safetyJSON: safetyJSON
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                // Save to Firestore
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
                hideAIStatus()
                print("❌ LLM fetch failed:", error)
            }
        }
    }


    // MARK: - JSON HELPERS
    func extractCategory(from json: String) -> String {
        (json.toJSONDict()?["category"] as? String) ?? "unknown"
    }

    func extractIngredients(from json: String) -> [String] {
        guard let dict = json.toJSONDict(),
              let items = dict["ingredients"] as? [[String: Any]]
        else { return [] }

        return items.compactMap { $0["name"] as? String }
    }
}


// MARK: - TABLE VIEW
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

        let item = filteredProducts[indexPath.row]

        cell.configure(
            name: item.name,
            safetyIndex: "\(item.safetyScore)"
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = filteredProducts[indexPath.row]

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


// MARK: - SCAN DELEGATE
extension SearchViewController: ScanDelegate {

    func didScanProduct(
        name: String,
        safetyScore: Int,
        pillColor: UIColor,
        ingredientInfoJSON: String,
        safetyJSON: String
    ) {
        // Add to local list
        let newItem = HistoryProduct(
            name: name,
            safetyScore: safetyScore,
            pillColor: pillColor,
            ingredientInfoJSON: ingredientInfoJSON,
            safetyJSON: safetyJSON
        )

        allProducts.insert(newItem, at: 0)
        filteredProducts = allProducts

        DispatchQueue.main.async {
            self.searchView.productsTableView.reloadData()
        }
    }
}


// MARK: - SEARCH VIEW DELEGATE
extension SearchViewController: SearchViewDelegate {

    func didTapScanButton() {
        let scanVC = ImageCaptureViewController()
        scanVC.scanDelegate = self
        navigationController?.pushViewController(scanVC, animated: true)
    }
}
