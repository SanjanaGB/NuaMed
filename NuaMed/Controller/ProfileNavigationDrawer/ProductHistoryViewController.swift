import UIKit
import FirebaseAuth

class ProductHistoryViewController: UIViewController {
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        
        let tableView = searchHistoryView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
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
        searchHistoryView.productsTableView.reloadData()
    }
}
    
extension ProductHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = filteredItems[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(
            name: entry.name,
            safetyIndex: String(entry.safetyScore)
        )
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = filteredItems[indexPath.row]

        let detailVC = ProductInfoViewController(
            name: entry.name,
            safetyScore: entry.safetyScore
        )
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.systemGray6
        } else {
            cell.backgroundColor = .white
        }
    }
    
    func filterSearchHistory(by category: String) {
        print("Selected category:", category)
        // Later: filter `items` by category and reload
    }
    
}
