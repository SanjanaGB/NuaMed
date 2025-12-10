import UIKit

extension UIColor {
    static let appBackground = UIColor(
        red: 0.80,
        green: 0.88,
        blue: 1.0,
        alpha: 1.0
    )

    static let appGradientTop    = UIColor.systemBlue
    static let appGradientBottom = UIColor.white
}

extension UIView {
    func applyAppBackgroundGradient() {
        // Remove any existing app gradient
        layer.sublayers?
            .filter { $0.name == "AppBackgroundGradientLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let gradient = CAGradientLayer()
        gradient.name = "AppBackgroundGradientLayer"
        gradient.colors = [
            UIColor.appGradientTop.cgColor,
            UIColor.appGradientBottom.cgColor
        ]
        gradient.locations = [0, 1]
        gradient.frame = bounds

        layer.insertSublayer(gradient, at: 0)
    }
}
