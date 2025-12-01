import UIKit

class IngredientDetailViewController: UIViewController {
    private let ingredient: Ingredient
    private let detailView = IngredientDetailView()
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailView.configure(title: ingredient.name,
                             body: ingredient.infoText)
        
        detailView.onCloseTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        detailView.onBackgroundTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func loadView(){
        view = detailView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
