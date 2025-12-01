import UIKit

class IngredientDetailView: UIView {
    var onCloseTapped: (() -> Void)?
    var onBackgroundTapped: (() -> Void)?
    
    private let backgroundView = UIView()
    private let cardView = UIView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func configure(title: String, body: String) {
        titleLabel.text = title
        textLabel.text = body
    }
    
    private func setupUI(){
        backgroundColor = .clear
        
        //MARK: outside card view
        //Dimmed background
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        
        let tappedOutside = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundView.addGestureRecognizer(tappedOutside)
            
        //MARK: The card view and everything inside the card view
        //Card view
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        addSubview(cardView)
        
        //Close button top right
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "xmark.circle")
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        cardView.addSubview(closeButton)

        //Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)
        
        //Body text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.numberOfLines = 0
        cardView.addSubview(textLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(scrollView)
        
        //The layout constraints
        NSLayoutConstraint.activate([
            //Card view constraints
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            //Card view constraints
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            cardView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.8),
            
            //Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 4),
            scrollView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            
            //Close button constraints
            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            
            //Title label constraints
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            //Text label constraints
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    @objc private func closeButtonTapped() {
        onCloseTapped?()
    }
    
    @objc private func handleBackgroundTap() {
        onBackgroundTapped?()
    }
}
