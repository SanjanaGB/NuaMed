import UIKit

class ProductTableViewCell: UITableViewCell {
    let itemImageView = UIImageView()
    let nameLabel = UILabel()
    let safetyIndexLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews(){
        //Item image (if any)
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.layer.cornerRadius = 17
        itemImageView.clipsToBounds = true
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Item name
        nameLabel.font = .systemFont(ofSize: 17)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //Item safety index
        safetyIndexLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        safetyIndexLabel.textColor = .gray
        safetyIndexLabel.setContentHuggingPriority(.required, for: .horizontal)
        safetyIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(itemImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(safetyIndexLabel)
    }
    
    private func setupConstraints(){
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 32),
            itemImageView.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: safetyIndexLabel.leadingAnchor, constant: -8),
            
            safetyIndexLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            safetyIndexLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(image: UIImage? = nil, name: String, safetyIndex: String){
        itemImageView.image = image ?? UIImage(systemName: "photo.circle.fill")
        nameLabel.text = name
        safetyIndexLabel.text = safetyIndex
    }

    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
}
