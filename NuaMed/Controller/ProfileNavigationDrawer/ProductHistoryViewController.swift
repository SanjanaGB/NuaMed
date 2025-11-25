import UIKit

class ProductHistoryViewController: UIViewController {
    let searchHistoryView = ProductHistoryView()
    private var searchedProducts: [Product] = []
    
    struct Product{
        let itemName: String
        let safetyIndex: String
    }
    
    override func viewDidLoad(){
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
        
        //Category dropdown menu
        searchHistoryView.categoryDropdown.onCategorySelected = { [weak self] category in self?.filterSearchHistory(by: category)
        }
        
        searchedProducts = [
                Product(itemName: "Shampoo", safetyIndex: "85"),
                Product(itemName: "Face cream", safetyIndex: "72")
            ]
            tableView.reloadData()
        
        //When search result should be added to history, call this function
        func addSearchedProduct(_ product: Product){
            searchedProducts.append(product)
            searchHistoryView.productsTableView.reloadData()
        }
//        
//        let label = UILabel()
////            label.text = "Your product history goes here"
//            label.font = .systemFont(ofSize: 20, weight: .medium)
//            label.translatesAutoresizingMaskIntoConstraints = false
//
//            view.addSubview(label)
//            NSLayoutConstraint.activate([
//                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//            ])
        
//        //Filter search history array based on the safety index
//        searchHistoryView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
//            print("Safety index range: \(minVal) – \(maxVal)")
//        }
//
//        loadSampleFavorites()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    override func loadView(){
        view = searchHistoryView
    }
}
    
extension ProductHistoryViewController: UITableViewDataSource, UITableViewDelegate {
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
        
        let product = searchedProducts[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

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
        
    func filterSearchHistory(by category: String) {
        print("Selected category:", category)
    }
    
}
