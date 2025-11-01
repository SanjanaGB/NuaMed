import UIKit

class AuthHeaderView: UIView {

    let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "NuaMed"
        l.font = .italicSystemFont(ofSize: 36)
        l.textColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0) // navy blue
        l.textAlignment = .center
        return l
    }()

    let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "Allergy-aware, everywhere"
        l.font = .italicSystemFont(ofSize: 18)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    let imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "app_logo"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(logoLabel)
        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 16
        let titleHeight: CGFloat = 50
        let logoHeight: CGFloat = 24
        let imageHeight: CGFloat = bounds.height * 0.5

        titleLabel.frame = CGRect(
            x: margin,
            y: margin,
            width: bounds.width - margin * 2,
            height: titleHeight
        )

        logoLabel.frame = CGRect(
            x: margin,
            y: titleLabel.frame.maxY + 4,
            width: bounds.width - margin * 2,
            height: logoHeight
        )

        imageView.frame = CGRect(
            x: (bounds.width - imageHeight)/2,
            y: logoLabel.frame.maxY + 12,
            width: imageHeight,
            height: imageHeight
        )
    }
}

extension UIColor {
    func darker(by percentage: CGFloat = 20.0) -> UIColor {
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: max(r - percentage/100, 0),
                green: max(g - percentage/100, 0),
                blue: max(b - percentage/100, 0),
                alpha: a
            )
        }
        return self
    }
}
