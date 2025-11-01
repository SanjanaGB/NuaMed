import UIKit

protocol ProfileSetupViewDelegate: AnyObject {
    func didSaveProfile(
        name: String,
        gender: String,
        age: Int?,
        allergies: [String],
        medicalConditions: [String],
        medications: [String],
        profileImage: UIImage?
    )
    func didRequestChangeCredentials()
    func didTapBack()
    func didTapOpenList(for type: String)
}

class ProfileSetupView: UIView {

    weak var delegate: ProfileSetupViewDelegate?

    let scrollView = UIScrollView()
    let content = UIView()

    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill  // So real profile images fill circle nicely
        iv.backgroundColor = UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0) // light blue background
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor(red: 0.70, green: 0.82, blue: 0.95, alpha: 1.0).cgColor // optional subtle border

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
        let placeholder = UIImage(systemName: "person.fill", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)
        iv.image = placeholder
        iv.contentMode = .center

        return iv
    }()

    let addImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit Image", for: .normal)
        btn.setTitleColor(.white, for: .normal) // White text
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return btn
    }()


    let nameField = UITextField()
    let genderField = UITextField()
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Male", "Female", "Other"]
    let ageField = UITextField()

    let allergiesButton = UIButton(type: .system)
    let medicalConditionsButton = UIButton(type: .system)
    let medicationsButton = UIButton(type: .system)

    let changeCredsButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    var allergies: [String] = []
    var medicalConditions: [String] = []
    var medications: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(content)

        setupGenderPicker()
        setupUI()
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

    private func setupGenderPicker() {
        genderField.borderStyle = .roundedRect
        genderField.inputView = genderPicker
        genderPicker.delegate = self
        genderPicker.dataSource = self

        let placeholderColor = UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0)
        genderField.attributedPlaceholder = NSAttributedString(
            string: "Gender",
            attributes: [.foregroundColor: placeholderColor]
        )
    }

    private func setupUI() {
        nameField.styleForAuth(placeholderText: "Full Name")
        ageField.styleForAuth(placeholderText: "Age")
        ageField.keyboardType = .numberPad

        setupListButton(allergiesButton, title: "My Allergies")
        setupListButton(medicalConditionsButton, title: "My Medical Conditions")
        setupListButton(medicationsButton, title: "My Medications")

        changeCredsButton.setTitle("Change username/email/password", for: .normal)
        changeCredsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold) // Bolder
        changeCredsButton.addTarget(self, action: #selector(changeCredsTapped), for: .touchUpInside)

        saveButton.setTitle("Save Profile", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold) // Bigger & bold
        saveButton.setTitleColor(.white, for: .normal) // White text
        saveButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0) // Navy blue
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)

        [profileImageView, addImageButton,
         nameField, genderField, ageField,
         changeCredsButton,
         allergiesButton, medicalConditionsButton, medicationsButton,
         saveButton].forEach { content.addSubview($0) }
    }

    private func setupListButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold) // Bolder font
        button.contentHorizontalAlignment = .center // Centered horizontally
        button.addTarget(self, action: #selector(listButtonTapped(_:)), for: .touchUpInside)
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        applyVerticalGradient(top: UIColor.systemBlue, bottom: UIColor.white)
        scrollView.frame = bounds
        content.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1200)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2

        let margin: CGFloat = 20
        var y: CGFloat = 40

        profileImageView.frame = CGRect(x: (bounds.width - 80)/2, y: y, width: 80, height: 80)
        y = profileImageView.frame.maxY + 10 // small tweak
        addImageButton.frame = CGRect(x: (bounds.width - 180)/2, y: y, width: 180, height: 32)
        y += 60 // increased spacing before name field

        nameField.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 50
        genderField.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 50
        ageField.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 60

        changeCredsButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 60

        allergiesButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 50
        medicalConditionsButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 50
        medicationsButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 44)
        y += 60

        saveButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 60) // Taller than other buttons

        scrollView.contentSize = CGSize(width: bounds.width, height: saveButton.frame.maxY + 40)
    }

    @objc private func changeCredsTapped() { delegate?.didRequestChangeCredentials() }
    
    @objc private func listButtonTapped(_ sender: UIButton) {
        if sender == allergiesButton {
            delegate?.didTapOpenList(for: "Allergies")
        } else if sender == medicalConditionsButton {
            delegate?.didTapOpenList(for: "Medical Conditions")
        } else if sender == medicationsButton {
            delegate?.didTapOpenList(for: "Medications")
        }
    }

    @objc private func saveTapped() {
        let name = nameField.text ?? ""
        let gender = genderField.text ?? "Other"
        let age = Int(ageField.text ?? "")
        delegate?.didSaveProfile(
            name: name,
            gender: gender,
            age: age,
            allergies: allergies,
            medicalConditions: medicalConditions,
            medications: medications,
            profileImage: profileImageView.image
        )
    }

    @objc private func addImageTapped() {
        (parentViewController() as? ProfileSetupViewController)?.didTapChooseImage()
    }

    func setCapturedImage(_ image: UIImage?) {
        if let image = image {
            profileImageView.image = image
            profileImageView.contentMode = .scaleAspectFill
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
            let placeholder = UIImage(systemName: "photo", withConfiguration: symbolConfig)?
                .withTintColor(UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)
            profileImageView.image = placeholder
            profileImageView.contentMode = .center
        }
    }
}


extension ProfileSetupView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { genderOptions.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { genderOptions[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genderOptions[row]
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
