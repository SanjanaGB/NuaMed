import UIKit

protocol ImageCaptureViewDelegate: AnyObject {
    func didTapChooseImage()
    func didTapSubmit(image: UIImage?)
    func didTapLogout()
}

class ImageCaptureView: UIView {

    weak var delegate: ImageCaptureViewDelegate?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
        let placeholder = UIImage(systemName: "photo", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)
        iv.image = placeholder
        iv.contentMode = .center
        return iv
    }()

    let uploadButton = UIButton(type: .system)
    let submitButton = UIButton(type: .system)
    let logoutButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupScrollView()
        setupButtons()
        addSubviews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupButtons() {
        uploadButton.setTitle("Upload Image", for: .normal)
        uploadButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        uploadButton.setTitleColor(.systemBlue, for: .normal)
        uploadButton.backgroundColor = .clear
        uploadButton.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)

        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        submitButton.setTitleColor(.systemBlue, for: .normal)
        submitButton.backgroundColor = .clear
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0) // Navy
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func addSubviews() {
        [imageView, uploadButton, submitButton, logoutButton].forEach { contentView.addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyVerticalGradient(top: UIColor.systemBlue, bottom: UIColor.white)

        scrollView.frame = bounds
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1000) // temporary content height

        let margin: CGFloat = 40
        let buttonHeight: CGFloat = 50
        var y: CGFloat = 80

        let imageWidth = bounds.width - 80
        imageView.frame = CGRect(x: (bounds.width - imageWidth)/2, y: y, width: imageWidth, height: imageWidth)
        y = imageView.frame.maxY + 24

        uploadButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: buttonHeight)
        y = uploadButton.frame.maxY + 12

        submitButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: buttonHeight)
        y = submitButton.frame.maxY + 12

        logoutButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 60)
        y = logoutButton.frame.maxY + 40

        scrollView.contentSize = CGSize(width: bounds.width, height: y)
    }

    @objc private func uploadTapped() { delegate?.didTapChooseImage() }
    @objc private func submitTapped() { delegate?.didTapSubmit(image: imageView.image) }
    @objc private func logoutTapped() { delegate?.didTapLogout() }

    func setCapturedImage(_ image: UIImage?) {
        if let image = image {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
            let placeholder = UIImage(systemName: "photo", withConfiguration: symbolConfig)?
                .withTintColor(UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)
            imageView.image = placeholder
            imageView.contentMode = .center
        }
    }
}
