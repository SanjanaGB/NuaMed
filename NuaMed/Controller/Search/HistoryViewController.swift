import UIKit
import FirebaseAuth

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private var historyItems: [FirebaseService.HistoryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        title = "History"
        
        setupTableView()
        fetchHistory()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        FirebaseService.shared.fetchHistoryItems(forUserID: uid) { result in
            switch result {
            case .success(let items):
                self.historyItems = items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch history:", error)
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let item = historyItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        cell.textLabel?.text = "\(item.name) - Score: \(item.safetyScore)"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = historyItems[indexPath.row]
        
        let vc = ProductInfoViewController(
            name: item.name,
            safetyScore: item.safetyScore,
            pillColor: pillColor(for: item.safetyScore),
            ingredientInfoJSON: item.ingredientInfoJSON,    // ← IMPORTANT
            safetyJSON: item.safetyJSON                     // ← IMPORTANT
        )
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pillColor(for score: Int) -> UIColor {
        if score < 30 { return .systemRed }
        if score < 60 { return .systemYellow }
        return .systemGreen
    }
}
