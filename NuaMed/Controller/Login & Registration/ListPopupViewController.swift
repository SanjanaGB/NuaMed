import UIKit

protocol ListPopupDelegate: AnyObject {
    func didUpdateList(_ items: [String], forType type: String)
}

class ListPopupViewController: UIViewController {

    weak var delegate: ListPopupDelegate?
    private let type: String
    private var items: [String]
    private let popupView: ListPopupView

    init(title: String, items: [String], type: String) {
        self.items = items
        self.type = type
        self.popupView = ListPopupView(type: type)
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .formSheet
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = popupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.delegate = self
        popupView.updateItems(items)
        
        if let navBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    @objc private func doneTapped() {
        delegate?.didUpdateList(items, forType: type)
        dismiss(animated: true)
    }
}

// MARK: - ListPopupViewDelegate
extension ListPopupViewController: ListPopupViewDelegate {
    func didTapAdd(text: String) {
        items.append(text)
        popupView.updateItems(items)
        popupView.addField.text = ""
    }

    func didTapDelete(at index: Int) {
        items.remove(at: index)
        popupView.updateItems(items)
    }
}
