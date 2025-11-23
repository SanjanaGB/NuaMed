import UIKit

protocol LoginViewDelegate: AnyObject {
    func didTapLogin(username: String, password: String)
    func didTapRegister()
    func didTapForgotPassword(emailOrUsername: String?)
}

class LoginView: UIView {
    weak var delegate: LoginViewDelegate?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    let header = AuthHeaderView()
    let usernameField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton(type: .system)
    let registerButton = UIButton(type: .system)
    let forgotButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(header)
        [usernameField, passwordField, loginButton, registerButton, forgotButton].forEach { contentView.addSubview($0) }

        usernameField.styleForAuth(placeholderText: "Username/Email")
        passwordField.styleForAuth(placeholderText: "Password")
        passwordField.isSecureTextEntry = true

        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0) // Navy
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        registerButton.setTitle("Register", for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        forgotButton.setTitle("Forgot Password?", for: .normal)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)

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
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 600) // adjust height as needed
        scrollView.contentSize = contentView.frame.size

        let w = bounds.width
        header.frame = CGRect(x: 0, y: 60, width: w, height: 180)

        let margin: CGFloat = 24
        usernameField.frame = CGRect(x: margin, y: header.frame.maxY + 40, width: w - margin*2, height: 44)
        passwordField.frame = CGRect(x: margin, y: usernameField.frame.maxY + 12, width: w - margin*2, height: 44)

        loginButton.frame = CGRect(x: margin, y: passwordField.frame.maxY + 20, width: w - margin*2, height: 50)
        registerButton.frame = CGRect(x: margin, y: loginButton.frame.maxY + 12, width: w - margin*2, height: 40)
        forgotButton.frame = CGRect(x: margin, y: registerButton.frame.maxY + 8, width: w - margin*2, height: 30)
    }

    @objc private func loginTapped() {
        delegate?.didTapLogin(username: usernameField.text ?? "", password: passwordField.text ?? "")
    }

    @objc private func registerTapped() {
        delegate?.didTapRegister()
    }

    @objc private func forgotTapped() {
        delegate?.didTapForgotPassword(emailOrUsername: usernameField.text)
    }
}
