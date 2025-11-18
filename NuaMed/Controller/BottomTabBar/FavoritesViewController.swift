import UIKit

class FavoritesViewController: UIViewController {
    let favoritesView = FavoritesView()
    private var favoritedProducts: [Product] = []
    
    struct Product{
        let itemName: String
        let safetyIndex: String
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Favorites"
        
        let tableView = favoritesView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
        //Category dropdown menu
        favoritesView.categoryDropdown.onCategorySelected = { [weak self] category in self?.filterFavorites(by: category)
        }
        
        //When search result should be added to favorites, call this function
        func addFavoriteProduct(_ product: Product){
            favoritedProducts.append(product)
            favoritesView.productsTableView.reloadData()
        }
        
//        //Filter favorites array based on the safety index
//        favoritesView.onSafetyRangeChanged = { [weak self] minVal, maxVal in
//            print("Safety index range: \(minVal) – \(maxVal)")
//        }
//        
//        loadSampleFavorites()
    }
    
    override func loadView(){
        view = favoritesView
    }
}
    
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = favoritedProducts[indexPath.row]
        cell.textLabel?.text = "\(product.itemName)   \(product.safetyIndex)"
        cell.textLabel?.textColor = .black
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = favoritedProducts[indexPath.row]
        print("Selected:", product.itemName)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.systemGray6
        } else {
            cell.backgroundColor = .white
        }
    }
        
    func filterFavorites(by category: String) {
        print("Selected category:", category)
    }
    
}
