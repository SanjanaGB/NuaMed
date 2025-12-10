import UIKit

class ProductListViewController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private weak var tableView: UITableView?
    
    //Data source for the table
    var rows: [ProductRow] = []{
        didSet {
            tableView?.reloadData()
        }
    }
    
    //Callback for row selection
    var onSelectRow: ((ProductRow) -> Void)?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTable()
    }
   
    private func setupTable() {
        guard let tableView = tableView else { return }
        
        tableView.register(ProductTableViewCell.self,
                           forCellReuseIdentifier: "ProductCell")
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.rowHeight = 88
        tableView.estimatedRowHeight = 88
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell",
            for: indexPath
        ) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let row = rows[indexPath.row]
        cell.configure(name: row.name, safetyIndex: String(row.safetyScore))
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectRow?(rows[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}
