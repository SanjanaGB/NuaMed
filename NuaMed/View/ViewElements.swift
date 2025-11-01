import UIKit
import ObjectiveC

extension UIView {
    func applyVerticalGradient(top: UIColor = UIColor(red: 0.93, green: 0.97, blue: 1.0, alpha: 1.0), // very light blue
                               bottom: UIColor = .white) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [top.cgColor, bottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.name = "backgroundGradient"
        layer.sublayers?.filter { $0.name == "backgroundGradient" }.forEach { $0.removeFromSuperlayer() }
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, okTitle: String = "OK", onOk: (() -> Void)? = nil) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: okTitle, style: .default) { _ in onOk?() })
        present(a, animated: true)
    }
    
}

extension UITextField {
    func styleForAuth(placeholderText: String, placeholderColor: UIColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)) {
        borderStyle = .roundedRect
        autocorrectionType = .no
        autocapitalizationType = .none
        layer.cornerRadius = 8
        heightAnchor.constraint(equalToConstant: 44).isActive = true

        attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
    }
}


private struct AssociatedKeys {
    static var backActionKey = "backActionKey"
}

extension UIViewController {
    
    
    
    func setupNavigationBar(title: String,
                            prefersLargeTitles: Bool = false,
                            backAction: (() -> Void)? = nil) {
        self.title = title
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue

        let backImage = UIImage(systemName: "arrow.backward")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        if let backAction = backAction {
            objc_setAssociatedObject(self, &AssociatedKeys.backActionKey, backAction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        let separatorHeight: CGFloat = 1
        let separator = UIView(frame: CGRect(
            x: 0,
            y: navigationController?.navigationBar.frame.height ?? 44 - separatorHeight,
            width: view.frame.width,
            height: separatorHeight
        ))
        separator.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1) // Navy blue, same as gradient top
        separator.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        navigationController?.navigationBar.addSubview(separator)
    }
    


    @objc private func backTapped() {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.backActionKey) as? () -> Void {
            action()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
}
