import UIKit
import MultiSlider

class FavoritesView: UIView {
    var categoryFilterLabel: UILabel!
    var safetyIndexFilterLabel: UILabel!
    
    //var resultTextFieldLabel: UILabel!
    var itemLabel: UILabel!
    var itemNameLabel: UILabel!
    var safetyIndexLabel: UILabel!
    
    //Dropdown menu selections
    let categoryDropdown = DropdownMenuView(
        categories: ["All Categories", "Cosmetic Item", "Food Product", "Medication"],
        initialTitle: "All Categories"
    )
    
    //Range slider
    let safetyRangeSlider: MultiSlider = {
        let slider = MultiSlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = [0, 100]
        slider.orientation = .horizontal
        //Update while a user drags the slider
        slider.isContinuous = true
        slider.snapStepSize = 1
        
        //Style
        slider.tintColor = .white
        slider.outerTrackColor = UIColor.white.withAlphaComponent(0.3)
        slider.trackWidth = 6
        slider.hasRoundTrackEnds = true
        
        //Values in the bubbles
        slider.valueLabelPosition = .bottom
        slider.isValueLabelRelative = false
        slider.valueLabelColor = .white
        slider.valueLabelFont = .boldSystemFont(ofSize: 14)
        slider.valueLabelFormatter.minimumFractionDigits = 0
        slider.valueLabelFormatter.maximumFractionDigits = 0
        //Add a % sign if you like
        //slider.valueLabelFormatter.positiveSuffix = " %"
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    var onSafetyRangeChanged: ((Double, Double) -> Void)?
    
    //Table of products
    let productsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        //Dropdown menu
        setupCategoryDropdown()
        
        //Range slider
        addSubview(safetyRangeSlider)
        safetyRangeSlider.addTarget(self, action: #selector(safetySliderChanged(_:)), for: .valueChanged)
        
        //Filter labels
        setupCategoryFilterLabel()
        setupSafetyIndexFilterLabel()
        
        //Text labels above the table of products
        //setupResultTextField()
        setupItemLabel()
        setupItemNameLabel()
        setupSafetyIndexLabel()
        
        //Table of products
        setupProductsTableView()
        
        initConstraints()
    }
    
    //Category filter label
    func setupCategoryFilterLabel(){
        categoryFilterLabel = UILabel()
        categoryFilterLabel.text = "Filter by Category"
        categoryFilterLabel.font = UIFont.boldSystemFont(ofSize: 20)
        categoryFilterLabel.textColor = .white
        categoryFilterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryFilterLabel)
    }
        
    //Dropdown menu
    func setupCategoryDropdown(){
        categoryDropdown.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryDropdown)
    }
    
    //Safety Index filter label
    func setupSafetyIndexFilterLabel(){
        safetyIndexFilterLabel = UILabel()
        safetyIndexFilterLabel.text = "Filter by Safety Index"
        safetyIndexFilterLabel.font = UIFont.boldSystemFont(ofSize: 20)
        safetyIndexFilterLabel.textColor = .white
        safetyIndexFilterLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyIndexFilterLabel)
    }
    
//    func setupResultTextField() {
//        resultTextFieldLabel = UILabel()
//        resultTextFieldLabel.text = "Results"
//        resultTextFieldLabel.font = UIFont.boldSystemFont(ofSize: 20)
//        resultTextFieldLabel.textColor = .white
//        resultTextFieldLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(resultTextFieldLabel)
//    }
    
    func setupItemLabel() {
        itemLabel = UILabel()
        itemLabel.text = "Item"
        itemLabel.font = UIFont.boldSystemFont(ofSize: 17)
        itemLabel.textColor = .white
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemLabel)
    }
    
    func setupItemNameLabel() {
        itemNameLabel = UILabel()
        itemNameLabel.text = "Name"
        itemNameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        itemNameLabel.textColor = .white
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemNameLabel)
    }
    
    func setupSafetyIndexLabel() {
        safetyIndexLabel = UILabel()
        safetyIndexLabel.text = "Safety Index"
        safetyIndexLabel.font = UIFont.boldSystemFont(ofSize: 17)
        safetyIndexLabel.textColor = .white
        safetyIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safetyIndexLabel)
    }
    
    func setupProductsTableView() {
        productsTableView.tableFooterView = UIView()
        productsTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        productsTableView.isScrollEnabled = true
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        productsTableView.rowHeight = 88
        productsTableView.estimatedRowHeight = 88
        productsTableView.separatorStyle = .none
        productsTableView.backgroundColor = .clear
        addSubview(productsTableView)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            //Filter container
            categoryFilterLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7),
            categoryFilterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryFilterLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            //Category drowpdown menu
            categoryDropdown.topAnchor.constraint(equalTo: categoryFilterLabel.bottomAnchor, constant: 10),
            categoryDropdown.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryDropdown.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                       
            safetyIndexFilterLabel.topAnchor.constraint(equalTo: categoryDropdown.bottomAnchor, constant: 30),
            safetyIndexFilterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            safetyRangeSlider.topAnchor.constraint(equalTo: safetyIndexFilterLabel.bottomAnchor, constant: 16),
            safetyRangeSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            safetyRangeSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            safetyRangeSlider.heightAnchor.constraint(equalToConstant: 32),
            
            //Text labels: results, item, name, safety index
//            resultTextFieldLabel.topAnchor.constraint(equalTo: safetyRangeSlider.bottomAnchor, constant: 30),
//            resultTextFieldLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            itemLabel.topAnchor.constraint(equalTo: safetyRangeSlider.bottomAnchor, constant: 40),
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            itemNameLabel.centerYAnchor.constraint(equalTo: itemLabel.centerYAnchor),
            itemNameLabel.leadingAnchor.constraint(equalTo: itemLabel.trailingAnchor, constant: 35),
            
            safetyIndexLabel.topAnchor.constraint(equalTo: safetyRangeSlider.bottomAnchor, constant: 40),
            safetyIndexLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            //Products table
            productsTableView.topAnchor.constraint(equalTo: safetyIndexLabel.bottomAnchor, constant: 1),
            productsTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            productsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            productsTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func scanButtonTapped() {
        print("Scan button tapped")
    }
    
    //Handling the range slider values
    @objc private func safetySliderChanged(_ sender: MultiSlider) {
        guard sender.value.count == 2 else { return }
        let minVal = Double(sender.value[0])
        let maxVal = Double(sender.value[1])
        onSafetyRangeChanged?(minVal, maxVal)
    }
}
