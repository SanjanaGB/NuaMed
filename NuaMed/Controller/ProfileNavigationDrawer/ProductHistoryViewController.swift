import UIKit
import FirebaseAuth

class ProductHistoryViewController: UIViewController {
    private var listController: ProductListViewController!
    let searchHistoryView = ProductHistoryView()
    var items: [FirebaseService.HistoryItem] = []
    
    // Everything from Firestore
    private var allItems: [FirebaseService.HistoryItem] = []
    // What the table is currently showing
    private var filteredItems: [FirebaseService.HistoryItem] = []
    
    // Current safety filter range
    private var currentMinSafety = 0
    private var currentMaxSafety = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Search History"
        
        // Attach shared table controller
//        listController = ProductListTableController(tableView: searchHistoryView.productsTableView)
        listController = ProductListViewController(tableView: searchHistoryView.productsTableView)
        listController.onSelectRow = { [weak self] (row: ProductRow) in
            guard let self = self else { return }
            
            let detailVC = ProductInfoViewController(
                name: row.name,
                safetyScore: row.safetyScore,
                pillColor: self.colorFor(score: row.safetyScore),
                ingredientInfoJSON: "{}",   // placeholders because history does not store these
                safetyJSON: "{}"
            )
            
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        
        //Configure the safety range slider
        searchHistoryView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
            guard let self = self else { return }
            self.currentMinSafety = Int(minVal.rounded())
            self.currentMaxSafety = Int(maxVal.rounded())
            self.applyHistoryFilters()
        }
        
        // Category dropdown menu
        searchHistoryView.categoryDropdown.onCategorySelected = { [weak self] category in
            self?.filterSearchHistory(by: category)
        }
    }
    
    private func colorFor(score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            items = []
            searchHistoryView.productsTableView.reloadData()
            return
        }
        
        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Failed to fetch history items:", error)
                    self?.allItems = []
                    self?.filteredItems = []
                    self?.searchHistoryView.productsTableView.reloadData()
                    
                case .success(let history):
                    self?.allItems = history
                    self?.applyHistoryFilters()
                }
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    override func loadView(){
        view = searchHistoryView
    }
    
    private func applyHistoryFilters() {
        filteredItems = allItems.filter { item in
            let s = item.safetyScore
            return s >= currentMinSafety && s <= currentMaxSafety
        }
        listController.rows = filteredItems.map { entry in
            ProductRow(
                id: entry.productId,
                name: entry.name,
                safetyScore: entry.safetyScore,
                image: nil,
                ingredientInfoJSON: entry.ingredientInfoJSON,
                safetyJSON: entry.safetyJSON
            )
        }
    }
    
    private func filterSearchHistory(by category: String) {
        print("Selected category:", category)
        // Later: actually filter `allItems` by category and call applyHistoryFilters()
    }
    
}
