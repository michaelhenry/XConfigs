import Combine
import CombineCocoa
import UIKit

public final class XConfigsViewController: UITableViewController {
    typealias ViewModel = XConfigsViewModel
    typealias DataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

    private let viewModel: ViewModel
    private var subscriptions = Set<AnyCancellable>()

    private lazy var datasource: DataSource = {
        var ds = DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case let .toggle(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                cell.mainView.switchView.isOnPublisher
                    .sink { value in
                        print("VALUE", value)
                    }
                    .store(in: &cell.subscriptions)
                cell.selectionStyle = .none
                return cell
            case let .textInput(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<TextInputView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                return cell
            case let .optionSelection(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<TextInputView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                return cell
            }
        }
        return ds
    }()

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

        title = "XConfigs"
        tableView.registerCell(UIViewTableWrapperCell<ToggleView>.self)
        tableView.registerCell(UIViewTableWrapperCell<TextInputView>.self)
        tableView.registerCell(UIViewTableWrapperCell<OptionView>.self)

        handleViewModelOutput()
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleItemSelection(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func handleViewModelOutput() {
        let output = viewModel.transform(
            input: .init(reloadTrigger: Just(()).eraseToAnyPublisher()))

        output.sectionItemsModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] secItems in
                guard let self = self else { return }
                self.datasource.apply(secItems.snapshot(), animatingDifferences: false)
            }
            .store(in: &subscriptions)
    }

    private func handleItemSelection(_ indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        print("ITEM", item)
        switch item {
        case let .optionSelection(model):
            showOptionSelection(for: model)
        case let .textInput(model):
            showTextInputViewController(model: model)
        default:
            break
        }
    }

    private func showTextInputViewController(model: TextInputModel) {
        let textInputVC = TextInputViewController(viewModel: .init(title: model.key, value: model.value))
        let nvc = textInputVC.wrapInsideNavVC()

        // Sheet
        nvc.preferAsSheet()
        present(nvc, animated: true)
    }

    func showOptionSelection(for model: OptionSelectionModel) {
        let optionVC = OptionViewController(viewModel: .init(title: model.key, items: model.choices))
        let nvc = optionVC.wrapInsideNavVC()

        // Sheet
        nvc.preferAsSheet()
        present(nvc, animated: true)
    }
}
