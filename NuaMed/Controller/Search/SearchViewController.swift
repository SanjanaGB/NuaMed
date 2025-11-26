import UIKit

class SearchViewController: UIViewController, SearchViewDelegate {
    private let searchView = SearchView(frame: .zero)
    private var searchedProducts: [Product] = []

    
    struct Product{
        let itemName: String
        let safetyIndex: String
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Search"
        
        let tableView = searchView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
        searchedProducts = [
                Product(itemName: "Shampoo", safetyIndex: "85"),
                Product(itemName: "Face cream", safetyIndex: "72")
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
//        let product = searchedProducts[indexPath.row]
//        cell.textLabel?.text = "\(product.itemName)   \(product.safetyIndex)"
//        cell.textLabel?.textColor = .black
//        cell.accessoryType = .disclosureIndicator
//        return cell
        let product = searchedProducts[indexPath.row]   // or favoritedProducts, etc.

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        // Plug values into the cell
        cell.configure(name: product.itemName, safetyIndex: product.safetyIndex)
        // If you later have an image URL or asset, pass it here.

        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = searchedProducts[indexPath.row]
        
        let safetyInt = Int(product.safetyIndex) ?? 0
        
        let detailVC = ProductInfoViewController(
                name: product.itemName,
                safetyScore: safetyInt
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
}
