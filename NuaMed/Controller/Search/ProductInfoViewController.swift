import UIKit

class ProductInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let productInfoView = ProductInfoView()
    
    private let ingredients = ["Aqua", "Glycerin", "Perfume"]
    private let productName: String
    private let productSafetyScore: Int
    
    init(name: String, safetyScore: Int){
        self.productName = name
        self.productSafetyScore = safetyScore
        super.init(nibName: nil, bundle: nil)
        //hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productInfoView.configure(
            name: productName,
            safetyScore: productSafetyScore,
            allergens: ["Perfume", "Benzyl Alcohol"]
        )

        productInfoView.ingredientsTableView.dataSource = self
        productInfoView.ingredientsTableView.delegate = self
    }
    
    override func loadView(){
        view = productInfoView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "IngredientCell",
            for: indexPath
        ) as! ProductTableViewCell
        
        let ingredient = ingredients[indexPath.row]
        cell.textLabel?.text = ingredient
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
