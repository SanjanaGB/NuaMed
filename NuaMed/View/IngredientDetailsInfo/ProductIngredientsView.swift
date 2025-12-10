import UIKit

class ProductIngredientsView: UIView {
    var searchContainer: UIView!
    var searchFieldView: UISearchTextField!
    var scanningButton: UIButton!
    
    var resultTextFieldLabel: UILabel!
    var itemLabel: UILabel!
    var itemNameLabel: UILabel!
    var safetyIndexLabel: UILabel!
    
    //Table of products
    let productsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        //Search
        setupSearchContainer()
        setupSearchField()
        setupScanningImage()
        
        //Text labels above the table of products
        setupResultTextField()
        setupItemLabel()
        setupItemNameLabel()
        setupSafetyIndexLabel()
        
        //Table of products
        setupProductsTableView()
        
        initConstraints()
    }
    
    func setupSearchContainer() {
        searchContainer = UIView()
        searchContainer.backgroundColor = .white
        searchContainer.layer.cornerRadius = 12
        searchContainer.layer.masksToBounds = true
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchContainer)
    }
    
    func setupSearchField() {
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .gray
        icon.contentMode = .center
        icon.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        
        searchFieldView = UISearchTextField()
        searchFieldView.placeholder = "Search for an item"
        searchFieldView.borderStyle = .none
        searchFieldView.clearButtonMode = .whileEditing
        searchFieldView.leftView = icon
        searchFieldView.leftViewMode = .always
        searchFieldView.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.addSubview(searchFieldView)
    }
    
    func setupScanningImage() {
        scanningButton = UIButton(type: .system)
        scanningButton.translatesAutoresizingMaskIntoConstraints = false
        
        let scanImage = UIImage(systemName: "barcode.viewfinder")
        scanningButton.setImage(scanImage, for: .normal)
        scanningButton.tintColor = .black
        scanningButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        scanningButton.layer.cornerRadius = 8
        scanningButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        searchContainer.addSubview(scanningButton)
    }
    
    func setupResultTextField() {
        resultTextFieldLabel = UILabel()
        resultTextFieldLabel.text = "Results"
        resultTextFieldLabel.font = UIFont.boldSystemFont(ofSize: 20)
        resultTextFieldLabel.textColor = .white
        resultTextFieldLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(resultTextFieldLabel)
    }
    
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
        productsTableView.register(IngredientTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        productsTableView.isScrollEnabled = true
        productsTableView.translatesAutoresizingMaskIntoConstraints = false
        productsTableView.backgroundColor = .white
        addSubview(productsTableView)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            //Search container
            searchContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 44),
            
            //Scanning button (on the right side)
            scanningButton.topAnchor.constraint(equalTo: searchContainer.topAnchor, constant: 4),
            scanningButton.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: -4),
            scanningButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -4),
            scanningButton.widthAnchor.constraint(equalTo: scanningButton.heightAnchor),
            
            //Text field inside container (on the left side)
            searchFieldView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 8),
            searchFieldView.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchFieldView.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchFieldView.trailingAnchor.constraint(equalTo: scanningButton.leadingAnchor, constant: -8),
            
            // Text labels: results, item, name, safety index
            resultTextFieldLabel.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 25),
            resultTextFieldLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            itemLabel.topAnchor.constraint(equalTo: resultTextFieldLabel.bottomAnchor, constant: 16),
            itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            itemNameLabel.centerYAnchor.constraint(equalTo: itemLabel.centerYAnchor),
            itemNameLabel.leadingAnchor.constraint(equalTo: itemLabel.trailingAnchor, constant: 35),
            
            safetyIndexLabel.topAnchor.constraint(equalTo: resultTextFieldLabel.bottomAnchor, constant: 16),
            safetyIndexLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            //Products table
            productsTableView.topAnchor.constraint(equalTo: safetyIndexLabel.bottomAnchor, constant: 16),
            productsTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            productsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            productsTableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func scanButtonTapped() {
        print("Scan button tapped")
    }
}
