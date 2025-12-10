import UIKit
import FirebaseAuth

class SearchViewController: UIViewController, SearchViewDelegate {
    private let searchView = SearchView(frame: .zero)
    private var searchedProducts: [Product] = []
    
    struct Product{
        let itemName: String
        let safetyIndex: String
        let pillColor: UIColor
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Search"
        
        let tableView = searchView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
        searchedProducts = [
            Product(itemName: "Shampoo",
                    safetyIndex: "85",
                    pillColor: pillColor(for: 85)),
            Product(itemName: "Face cream",
                    safetyIndex: "32",
                    pillColor: pillColor(for: 32))
        ]
        
        tableView.reloadData()
    }
    
    override func loadView(){
        searchView.delegate = self
        view = searchView
    }
    
    //When search result should be added to history, call this function
    func addSearchedProduct(_ product: Product){
        searchedProducts.append(product)
        searchView.productsTableView.reloadData()
    }
    
    func didTapScanButton() {
        let scanVC = ImageCaptureViewController()
        navigationController?.pushViewController(scanVC, animated: true)
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = searchedProducts[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        // Plug values into the cell
        cell.configure(name: product.itemName, safetyIndex: product.safetyIndex)
        // If you later have an image URL or asset, pass it here.

        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = searchedProducts[indexPath.row]
        let safetyInt = Int(product.safetyIndex) ?? 0

        let detailVC = ProductInfoViewController(
            name: product.itemName,
            safetyScore: safetyInt,
            pillColor: product.pillColor
        )
        
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseService.shared.addHistoryItem(
                uid: uid,
                productId: product.itemName,
                name: product.itemName,
                category: "General",  // product.category
                safetyScore: safetyInt,
//                completion: <#T##((any Error)?) -> Void#>
            ){ error in
                if let error = error {
                    print("Error adding search history item:", error)
                }
            }
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //The color of the rows in the Search
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = .clear
        }
    }
}

private func pillColor(for score: Int) -> UIColor {
    // TODO: your real formula here
    if score < 20 { return .systemRed }
    if score < 50 { return .systemYellow }
    return .systemGreen
}
