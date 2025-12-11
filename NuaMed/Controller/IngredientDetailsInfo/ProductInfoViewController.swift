import UIKit
import FirebaseAuth

class ProductInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let productInfoView = ProductInfoView()

    private let productName: String
    private let productSafetyScore: Int
    private let pillColor: UIColor

    private var isFavorited = false

    private var ingredients: [Ingredient] = []
    private var combinedSafetyAlerts: [String] = []
    private var productCategory: String = "General"   // ⭐ default category

    private let ingredientInfoJSON: String
    private let safetyJSON: String

    // MARK: - INIT
    init(
        name: String,
        safetyScore: Int,
        pillColor: UIColor,
        ingredientInfoJSON: String,
        safetyJSON: String
    ) {
        self.productName = name
        self.productSafetyScore = safetyScore
        self.pillColor = pillColor
        self.ingredientInfoJSON = ingredientInfoJSON
        self.safetyJSON = safetyJSON

        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = productInfoView }

    // MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBlue

        setupTable()
        loadFavoriteState()

        parseIngredientInfo(ingredientInfoJSON)
        parseCategory(safetyJSON)
        processSafetyAlerts(safetyJSON)

        configureHeaderUI()

        productInfoView.onAlertsTapped = { [weak self] in
            self?.openSafetyAlertModal()
        }

        productInfoView.ingredientsTableView.reloadData()
    }

    // MARK: - TABLE CONFIG
    private func setupTable() {
        let table = productInfoView.ingredientsTableView
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.register(IngredientTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        table.separatorStyle = .none
    }

    // MARK: - CATEGORY PARSE
    private func parseCategory(_ json: String) {
        guard let dict = json.toJSONDict(),
              let cat = dict["category"] as? String else { return }

        let lower = cat.lowercased()
        print("🟩 LLM Returned Category:", lower)

        if lower.contains("food") {
            productCategory = "Food Product"
        } else if lower.contains("cosmetic") {
            productCategory = "Cosmetic Item"
        } else if lower.contains("medication") || lower.contains("drug") || lower.contains("medicine") {
            productCategory = "Medication"
        } else {
            productCategory = "General"   // ⭐ fallback
        }
    }

    // MARK: - SAFETY ALERT PROCESS
    private func processSafetyAlerts(_ json: String) {
        let (allergens, warnings) = extractSafetyAlerts(from: json)

        var alerts: [String] = []

        for a in allergens {
            alerts.append("⚠️ Allergen Match: \(a.capitalized)")
        }

        for w in warnings {
            alerts.append("⚡ \(w.ingredient): \(w.issue)")
        }

        combinedSafetyAlerts = alerts.isEmpty
            ? ["No safety concerns detected for your profile."]
            : alerts
    }

    private func openSafetyAlertModal() {
        let vc = SafetyAlertsModalViewController(alerts: combinedSafetyAlerts)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    // MARK: - HEADER
    private func configureHeaderUI() {
        productInfoView.configure(
            name: productName,
            safetyScore: productSafetyScore,
            allergens: combinedSafetyAlerts,
            pillColor: pillColor,
            category: productCategory
        )
    }

    // MARK: - FAVORITE HANDLING
    private func loadFavoriteState() {
        isFavorited = Favorites.shared.checkIfFavorited(named: productName)
        productInfoView.updateFavoriteStarIcon(systemName: isFavorited ? "star.fill" : "star")

        productInfoView.onFavoriteTapped = { [weak self] in
            self?.toggleFavorite()
        }
    }

    private func toggleFavorite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // ⭐ Always guarantee a usable category
        let safeCategory = productCategory.isEmpty ? "General" : productCategory

        if isFavorited {
            // REMOVE
            Favorites.shared.removeProduct(named: productName)
            FirebaseService.shared.removeFavoriteItem(uid: uid, productId: productName) { _ in }
            isFavorited = false

        } else {
            // ADD
            let fav = FavoriteProduct(
                name: productName,
                safetyScore: productSafetyScore,
                category: safeCategory,
                ingredientInfoJSON: ingredientInfoJSON,
                safetyJSON: safetyJSON
            )

            Favorites.shared.addProduct(fav)

            FirebaseService.shared.addFavoriteItem(
                uid: uid,
                productId: productName,
                name: productName,
                category: safeCategory,   // ⭐ stored correctly
                safetyScore: productSafetyScore,
                ingredientInfoJSON: ingredientInfoJSON,
                safetyJSON: safetyJSON
            ) { err in
                if let err = err { print("🔥 Favorite save error:", err) }
            }

            isFavorited = true
        }

        productInfoView.updateFavoriteStarIcon(systemName: isFavorited ? "star.fill" : "star")
    }

    // MARK: - INGREDIENT PARSE
    private func parseIngredientInfo(_ json: String) {
        guard let dict = json.toJSONDict(),
              let list = dict["ingredients"] as? [[String: Any]]
        else { return }

        ingredients = list.compactMap { item in
            Ingredient(
                name: item["name"] as? String ?? "",
                safety: IngredientSafety(rawValue: item["safetyLevel"] as? Int ?? 0) ?? .safe,
                infoText: item["info"] as? String ?? ""
            )
        }
    }

    // MARK: - TABLEVIEW DATA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "IngredientCell",
            for: indexPath
        ) as? IngredientTableViewCell else {
            return UITableViewCell()
        }

        let ing = ingredients[indexPath.row]
        cell.configure(with: ing)

        cell.onInfoTapped = { [weak self] in
            self?.present(IngredientDetailViewController(ingredient: ing), animated: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ing = ingredients[indexPath.row]
        present(IngredientDetailViewController(ingredient: ing), animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
