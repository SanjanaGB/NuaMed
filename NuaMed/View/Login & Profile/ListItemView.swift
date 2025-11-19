import UIKit

class ListItemCell: UITableViewCell {
    
    static let identifier = "ListItemCell"
    
    let titleLabel = UILabel()
    let deleteButton = UIButton(type: .system)
    
    var deleteAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1.0)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.systemBlue
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        deleteButton.setTitle("−", for: .normal)
        deleteButton.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0), for: .normal) // navy blue
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        deleteButton.backgroundColor = .clear
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        contentView.backgroundColor = UIColor(red: 0.90, green: 0.95, blue: 1.0, alpha: 1.0)
        contentView.addSubview(titleLabel)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }

    
    @objc private func deleteTapped() {
        deleteAction?()
    }
}
