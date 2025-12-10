import UIKit
import FirebaseAuth

class ProductInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let productInfoView = ProductInfoView()

    private let productName: String
    private let productSafetyScore: Int
    private let pillColor: UIColor

    private var isFavorited = false

    // LLM DATA
    private var ingredients: [Ingredient] = []
    private var allergens: [String] = []
    private var warnings: [String] = []

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LOAD VIEW
    override func loadView() {
        view = productInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBlue

        parseIngredientInfo(ingredientInfoJSON)
        parseSafetyJSON(safetyJSON)
        checkUserAllergies()  
        setupTable()
        configureHeaderUI()
        loadFavoriteState()

        // Reload AFTER parsing
        productInfoView.ingredientsTableView.reloadData()
    }

    // MARK: - UI CONFIG
    private func setupTable() {
        let table = productInfoView.ingredientsTableView

        table.register(IngredientTableViewCell.self, forCellReuseIdentifier: "IngredientCell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.rowHeight = 48
        table.backgroundColor = .clear
    }
    
    private func checkUserAllergies() {
        guard let user = UserProfileManager.shared.currentUser else { return }

        let userAllergies = user.allergies.map { $0.lowercased() }

        // Scan every ingredient
        for ing in ingredients {
            let name = ing.name.lowercased()

            for allergy in userAllergies {
                if name.contains(allergy) {
                    allergens.append("⚠︎ Contains your allergen: \(allergy.capitalized)")
                }
            }
        }
    }


    private func configureHeaderUI() {

        let allergensText = allergens.isEmpty
            ? "No known allergens detected."
            : allergens.joined(separator: "\n")

        productInfoView.configure(
            name: productName,
            safetyScore: productSafetyScore,
            allergens: allergensText.components(separatedBy: "\n"),
            pillColor: pillColor
        )
    }

    // MARK: - FAVORITES
    private func loadFavoriteState() {
        isFavorited = Favorites.shared.checkIfFavorited(named: productName)
        updateFavoriteStarIcon()

        productInfoView.onFavoriteTapped = { [weak self] in
            self?.toggleFavorite()
        }
    }

    @objc private func toggleFavorite() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if isFavorited {
            // REMOVE FAVORITE
            Favorites.shared.removeProduct(named: productName)
            FirebaseService.shared.removeFavoriteItem(uid: uid, productId: productName) { _ in }
            isFavorited = false

        } else {
            let newFav = FavoriteProduct(
                name: productName,
                safetyScore: productSafetyScore,
                ingredientInfoJSON: ingredientInfoJSON,
                safetyJSON: safetyJSON
            )

            Favorites.shared.addProduct(newFav)

            FirebaseService.shared.addFavoriteItem(
                uid: uid,
                productId: productName,
                name: productName,
                category: "General",
                safetyScore: productSafetyScore,
                ingredientInfoJSON: ingredientInfoJSON,
                safetyJSON: safetyJSON
            ) { error in
                if let e = error { print("Favorite save error:", e) }
            }

            isFavorited = true
        }


        updateFavoriteStarIcon()
    }


    private func updateFavoriteStarIcon() {
        productInfoView.updateFavoriteStarIcon(systemName: isFavorited ? "star.fill" : "star")
    }

    // MARK: - JSON PARSING (GROQ)
    private func parseIngredientInfo(_ json: String) {
        guard
            let dict = json.toJSONDict(),
            let list = dict["ingredients"] as? [[String: Any]]
        else { return }

        var cleaned: [[String: Any]] = []
        var buffer: [String: Any]? = nil

        for item in list {
            let name = item["name"] as? String ?? ""

            // Case 1: broken start: "CAFFEINE(8"
            if name.contains("("), !name.contains(")") {
                buffer = item
                continue
            }

            // Case 2: second half: "3 mg/100 g)"
            if let b = buffer, name.contains(")") {
                let mergedName = (b["name"] as? String ?? "") + " " + name
                cleaned.append([
                    "name": mergedName,
                    "info": b["info"] as? String ?? "",
                    "safetyLevel": b["safetyLevel"] as? Int ?? 0
                ])
                buffer = nil
                continue
            }

            // Normal entry
            cleaned.append(item)
        }

        if let leftover = buffer {
            cleaned.append(leftover)
        }

        self.ingredients = cleaned.compactMap { item in
            let name = item["name"] as? String ?? ""
            let info = item["info"] as? String ?? ""
            let level = item["safetyLevel"] as? Int ?? 0

            return Ingredient(
                name: name,
                safety: IngredientSafety(rawValue: level) ?? .safe,
                infoText: info
            )
        }
    }

    private func parseSafetyJSON(_ json: String) {
        guard let dict = json.toJSONDict() else { return }

        self.allergens = dict["allergenMatches"] as? [String] ?? []

        // Convert warnings into readable strings
        if let warnList = dict["warnings"] as? [[String: Any]] {
            self.warnings = warnList.compactMap { item in
                guard
                    let ing = item["ingredient"] as? String,
                    let issue = item["issue"] as? String
                else { return nil }

                return "\(ing): \(issue)"
            }
        }
    }

    // MARK: - TABLEVIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "IngredientCell",
            for: indexPath
        ) as? IngredientTableViewCell else {
            return UITableViewCell()
        }

        let ing = ingredients[indexPath.row]
        cell.configure(with: ing)

        cell.onInfoTapped = { [weak self] in
            guard let self = self else { return }
            let vc = IngredientDetailViewController(ingredient: ing)
            self.present(vc, animated: true)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ing = ingredients[indexPath.row]
        let vc = IngredientDetailViewController(ingredient: ing)
        present(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
