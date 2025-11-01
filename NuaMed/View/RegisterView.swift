import UIKit

protocol RegisterViewDelegate: AnyObject {
    func didTapRegister(username: String, email: String, password: String)
    func didTapBackToLogin()
}

class RegisterView: UIView {
    weak var delegate: RegisterViewDelegate?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let header = AuthHeaderView()
    let usernameField = UITextField()
    let emailField = UITextField()
    let passwordField = UITextField()
    let registerButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(header)
        [usernameField, emailField, passwordField, registerButton, backButton].forEach { contentView.addSubview($0) }

        usernameField.styleForAuth(placeholderText: "Username")
        emailField.styleForAuth(placeholderText: "Email")
        emailField.keyboardType = .emailAddress
        passwordField.styleForAuth(placeholderText: "Password")
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .oneTimeCode // disables strong password suggestion
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.spellCheckingType = .no

        registerButton.setTitle("Register", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0) // Navy
        registerButton.layer.cornerRadius = 10
        registerButton.clipsToBounds = true
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        backButton.setTitle("Back to Login", for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        setupDismissKeyboardGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false // So buttons still work
        scrollView.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyVerticalGradient(top: UIColor.systemBlue, bottom: UIColor.white)

        scrollView.frame = bounds
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 700) // Adjust height as needed
        scrollView.contentSize = contentView.frame.size

        let w = bounds.width
        header.frame = CGRect(x: 0, y: 60, width: w, height: 160)

        let margin: CGFloat = 24
        usernameField.frame = CGRect(x: margin, y: header.frame.maxY + 40, width: w - margin*2, height: 44)
        emailField.frame = CGRect(x: margin, y: usernameField.frame.maxY + 8, width: w - margin*2, height: 44)
        passwordField.frame = CGRect(x: margin, y: emailField.frame.maxY + 8, width: w - margin*2, height: 44)
        registerButton.frame = CGRect(x: margin, y: passwordField.frame.maxY + 20, width: w - margin*2, height: 50)
        backButton.frame = CGRect(x: margin, y: registerButton.frame.maxY + 12, width: w - margin*2, height: 40)
    }

    @objc private func registerTapped() {
        delegate?.didTapRegister(username: usernameField.text ?? "", email: emailField.text ?? "", password: passwordField.text ?? "")
    }

    @objc private func backTapped() {
        delegate?.didTapBackToLogin()
    }
}
