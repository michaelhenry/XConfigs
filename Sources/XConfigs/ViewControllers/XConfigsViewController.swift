import UIKit

public final class XConfigsViewController: UITableViewController {
    private let viewModel: XConfigsViewModel

    public init(viewModel: XConfigsViewModel = .init()) {
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
        tableView.registerCell(UIViewTableWrapperCell<ToggleView>.self)
        tableView.registerCell(UIViewTableWrapperCell<TextInputView>.self)
        tableView.registerCell(UIViewTableWrapperCell<OptionView>.self)
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        viewModel.sectionItemsModels.count
    }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sectionItemsModels[section].items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.sectionItemsModels[indexPath.section].items[indexPath.row]
        switch item {
        case let .toggle(vm):
            let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
            cell.configure(with: (vm.key, vm.value))
            cell.selectionStyle = .none
            return cell
        case let .textInput(vm):
            let cell = tableView.dequeueCell(UIViewTableWrapperCell<TextInputView>.self, for: indexPath)
            cell.configure(with: (vm.key, vm.value))
            cell.selectionStyle = .none
            return cell
        case let .optionSelection(vm):
            let cell = tableView.dequeueCell(UIViewTableWrapperCell<TextInputView>.self, for: indexPath)
            cell.configure(with: (vm.key, vm.value))
            return cell
        }
    }
}
