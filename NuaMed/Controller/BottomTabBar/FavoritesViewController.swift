import UIKit

class FavoritesViewController: UIViewController {
    let favoritesView = FavoritesView()
    private var favoritedProducts: [FavoriteProduct] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBlue
        title = "Favorites"
        
        let tableView = favoritesView.productsTableView
        tableView.dataSource = self
        tableView.delegate = self
        
        //Category dropdown menu
        favoritesView.categoryDropdown.onCategorySelected = { [weak self] category in
            self?.filterFavorites(by: category)
        }
        
        //When search result should be added to favorites, call this function
        func addFavoriteProduct(_ product: FavoriteProduct){
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
    
    //Get the products from the Favorites file
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritedProducts = Favorites.shared.products
        favoritesView.productsTableView.reloadData()
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
        let product = favoritedProducts[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }

        // Plug values into the cell
        cell.configure(name: product.name, safetyIndex: String(product.safetyScore))
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = favoritedProducts[indexPath.row]
        
//        let safetyInt = Int(product.safetyIndex) ?? 0
        
        let detailVC = ProductInfoViewController(
                name: product.name,
                safetyScore: product.safetyScore
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
        
    func filterFavorites(by category: String) {
        print("Selected category:", category)
    }
    
}
