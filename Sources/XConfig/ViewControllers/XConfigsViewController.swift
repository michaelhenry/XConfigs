import UIKit

public final class XConfigsViewController: UITableViewController {
    private let viewModel: XConfigsViewModel

    public init(viewModel: XConfigsViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sectionItemsModels[section].items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        let item = viewModel.sectionItemsModels[indexPath.section].items[indexPath.row]
        cell?.textLabel?.text = item.displayName
        return cell ?? UITableViewCell()
    }
}

private extension XConfigsViewModel.Item {
    var displayName: String? {
        switch self {
        case let .optionSelection(vm):
            return vm.key
        case let .textInput(vm):
            return vm.key
        case let .toggle(vm):
            return vm.key
        }
    }
}
