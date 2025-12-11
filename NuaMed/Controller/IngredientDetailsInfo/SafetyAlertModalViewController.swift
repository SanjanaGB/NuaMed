import UIKit

class SafetyAlertsModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let alerts: [String]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Safety Alerts"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        return button
    }()

    init(alerts: [String]) {
        self.alerts = alerts
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 34/255, green: 50/255, blue: 85/255, alpha: 1)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AlertCell.self, forCellReuseIdentifier: "AlertCell")

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        layoutUI()
    }

    private func layoutUI() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }


    @objc private func closeTapped() {
        dismiss(animated: true)
    }


    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AlertCell",
            for: indexPath
        ) as? AlertCell else {
            return UITableViewCell()
        }

        cell.configure(text: alerts[indexPath.row])
        return cell
    }
}


// MARK: - Custom Alert Cell
class AlertCell: UITableViewCell {

    private let alertLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear

        contentView.addSubview(alertLabel)
        alertLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            alertLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            alertLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            alertLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            alertLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) {
        alertLabel.text = text
    }
}
