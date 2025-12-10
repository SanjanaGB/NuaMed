import UIKit

protocol ListPopupViewDelegate: AnyObject {
    func didTapAdd(text: String)
    func didTapDelete(at index: Int)
}

class ListPopupView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: ListPopupViewDelegate?
    
    private(set) var items: [String] = []
    private let tableView = UITableView()
    let addField = UITextField()
    private let addButton = UIButton(type: .system)
    private let type: String
    
    init(type: String) {
        self.type = type
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        // Pale light blue background
        backgroundColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1.0)
        
        // Add Field
        addField.placeholder = "Add new \(type.lowercased())"
        addField.borderStyle = .roundedRect
        addField.backgroundColor = .white
        addField.translatesAutoresizingMaskIntoConstraints = false
        
        // Set placeholder text color to light blue
        addField.attributedPlaceholder = NSAttributedString(
            string: "Add new \(type.lowercased())",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0)]
        )
        
        // Add Button - transparent with blue text
        addButton.setTitle("Add", for: .normal)
        addButton.setTitleColor(UIColor.systemBlue, for: .normal)
        addButton.backgroundColor = .clear
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1.0)
        
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.contentInset = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        [addField, addButton, tableView].forEach { addSubview($0) }
        
        NSLayoutConstraint.activate([
            addField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            addField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            addField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            addField.heightAnchor.constraint(equalToConstant: 40),
            
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: addField.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: addField.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame.size.width = bounds.width
        tableView.frame.origin.x = 0 // ensures full width after rotation
    }

    
    func updateItems(_ newItems: [String]) {
        self.items = newItems
        tableView.reloadData()
    }
    
    @objc private func addTapped() {
        guard let text = addField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty, !items.contains(text) else { return }
        delegate?.didTapAdd(text: text)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.identifier, for: indexPath) as! ListItemCell
        cell.titleLabel.text = items[indexPath.row]
        cell.selectionStyle = .none
        
        cell.deleteAction = { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapDelete(at: indexPath.row)
        }
        
        return cell
    }
}
