import UIKit

protocol ProfileSetupViewDelegate: AnyObject {
    func deleteUserAccount()
    func didSaveProfile(
        name: String,
        gender: String,
        dob: Date?,
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
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0)
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor(red: 0.70, green: 0.82, blue: 0.95, alpha: 1.0).cgColor
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
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return btn
    }()

    let nameField = UITextField()
    let genderField = UITextField()
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Male", "Female"]
    let dobField = UITextField()
    private let dobPicker = UIDatePicker()
    let ageField = UITextField()

    // Labels for fields
    private let nameLabel = UILabel()
    private let genderLabel = UILabel()
    private let dobLabel = UILabel()
    private let ageLabel = UILabel()

    let allergiesButton = UIButton(type: .system)
    let medicalConditionsButton = UIButton(type: .system)
    let medicationsButton = UIButton(type: .system)

    let changeCredsButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    var allergies: [String] = []
    var medicalConditions: [String] = []
    var medications: [String] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.addSubview(content)

        setupFieldLabels()
        setupDOBPicker()
        setupGenderPicker()
        setupUI()
        setupDismissKeyboardGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupFieldLabels() {
        let labels = [(nameLabel, "Full Name"),
                      (genderLabel, "Gender"),
                      (dobLabel, "DOB"),
                      (ageLabel, "Age")]

        for (label, text) in labels {
            label.text = text
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            label.textColor = .systemBlue
            content.addSubview(label)
        }
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
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

        genderField.attributedPlaceholder = NSAttributedString(
            string: "Gender",
            attributes: [.foregroundColor: UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0)]
        )
    }

    private func setupDOBPicker() {
        dobField.borderStyle = .roundedRect
        dobField.placeholder = "Date of Birth"

        dobPicker.datePickerMode = .date
        dobPicker.preferredDatePickerStyle = .wheels
        dobPicker.maximumDate = Date()
        dobPicker.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())

        dobPicker.addTarget(self, action: #selector(dobChanged), for: .valueChanged)
        dobField.inputView = dobPicker
        
        dobField.attributedPlaceholder = NSAttributedString(
            string: "Date of Birth",
            attributes: [
                .foregroundColor: UIColor(red: 0.68, green: 0.80, blue: 1.0, alpha: 1.0) // same blue as gender
            ]
        )
    }

    private func setupUI() {
        nameField.styleForAuth(placeholderText: "Full Name")
        ageField.styleForAuth(placeholderText: "Age")
        ageField.keyboardType = .numberPad

        setupListButton(allergiesButton, title: "My Allergies")
        setupListButton(medicalConditionsButton, title: "My Medical Conditions")
        setupListButton(medicationsButton, title: "My Medications")

        saveButton.setTitle("Save Profile", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0)
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        deleteButton.setTitle("Delete Account", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        changeCredsButton.setTitle("Change username/email/password", for: .normal)
        changeCredsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        changeCredsButton.addTarget(self, action: #selector(changeCredsTapped), for: .touchUpInside)

        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)

        // Add all fields/buttons
        [profileImageView, addImageButton,
         nameLabel, nameField,
         genderLabel, genderField,
         dobLabel, dobField,
         ageLabel, ageField,
         allergiesButton, medicalConditionsButton, medicationsButton,
         saveButton, changeCredsButton,deleteButton].forEach { content.addSubview($0) }
    }

    private func setupListButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(listButtonTapped(_:)), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyVerticalGradient(top: UIColor.systemBlue, bottom: UIColor.white)
        scrollView.frame = bounds
        content.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 1500)

        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2

        let margin: CGFloat = 20
        var y: CGFloat = 20 // moved up slightly

        // Profile Image
        profileImageView.frame = CGRect(x: (bounds.width - 80)/2, y: y, width: 80, height: 80)
        y = profileImageView.frame.maxY + 8
        addImageButton.frame = CGRect(x: (bounds.width - 180)/2, y: y, width: 180, height: 32)
        y += 50

        // Labels & Text fields
        let labelWidth: CGFloat = 90
        let fieldX = margin + labelWidth + 8 // reduced gap between label and field
        let fieldWidth = bounds.width - fieldX - margin
        let fieldHeight: CGFloat = 44
        let labelFontSize: CGFloat = 12

        func layoutField(label: UILabel, field: UITextField) {
            label.font = UIFont.systemFont(ofSize: labelFontSize, weight: .medium)
            label.frame = CGRect(x: margin, y: y + 14, width: labelWidth, height: 18)
            field.frame = CGRect(x: fieldX, y: y, width: fieldWidth, height: fieldHeight)
        }

        layoutField(label: nameLabel, field: nameField)
        y += fieldHeight + 12

        layoutField(label: genderLabel, field: genderField)
        y += fieldHeight + 12

        layoutField(label: dobLabel, field: dobField)
        y += fieldHeight + 12

        layoutField(label: ageLabel, field: ageField)
        y += fieldHeight + 16

        // List buttons (dynamic size, centered)
        let listButtons = [allergiesButton, medicationsButton, medicalConditionsButton]
        for button in listButtons {
            let textSize = button.titleLabel?.intrinsicContentSize ?? CGSize(width: 100, height: 20)
            let buttonWidth = textSize.width + 24
            let buttonHeight = textSize.height + 14
            button.frame = CGRect(x: (bounds.width - buttonWidth)/2, y: y, width: buttonWidth, height: buttonHeight)
            y += buttonHeight + 12
        }

        // Save button (full width)
        saveButton.frame = CGRect(x: margin, y: y, width: bounds.width - 2*margin, height: 60)
        y += 70

        // Change & Delete buttons (dynamic size, centered)
        let actionButtons = [changeCredsButton, deleteButton]
        for button in actionButtons {
            let textSize = button.titleLabel?.intrinsicContentSize ?? CGSize(width: 100, height: 20)
            let buttonWidth = textSize.width + 24
            let buttonHeight = textSize.height + 14
            button.frame = CGRect(x: (bounds.width - buttonWidth)/2, y: y, width: buttonWidth, height: buttonHeight)
            y += buttonHeight + 16
        }

        scrollView.contentSize = CGSize(width: bounds.width, height: deleteButton.frame.maxY + 40)
    }




    @objc private func changeCredsTapped() { delegate?.didRequestChangeCredentials() }
    @objc private func deleteTapped() {delegate?.deleteUserAccount()}
    
    @objc private func listButtonTapped(_ sender: UIButton) {
        if sender == allergiesButton { delegate?.didTapOpenList(for: "Allergies") }
        else if sender == medicalConditionsButton { delegate?.didTapOpenList(for: "Medical Conditions") }
        else if sender == medicationsButton { delegate?.didTapOpenList(for: "Medications") }
    }
    @objc private func saveTapped() {
        let name = nameField.text ?? ""
        let gender = genderField.text ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dobDate = formatter.date(from: dobField.text ?? "")
        let age = Int(ageField.text ?? "")
        delegate?.didSaveProfile(
            name: name,
            gender: gender,
            dob: dobDate,
            age: age,
            allergies: allergies,
            medicalConditions: medicalConditions,
            medications: medications,
            profileImage: profileImageView.image
        )
    }

    func calculateAge(from dob: Date) -> Int {
        let now = Date()
        let age = Calendar.current.dateComponents([.year], from: dob, to: now).year ?? 0
        return max(age, 0)
    }

    @objc func dobChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dobField.text = formatter.string(from: dobPicker.date)
        ageField.text = "\(calculateAge(from: dobPicker.date))"
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
