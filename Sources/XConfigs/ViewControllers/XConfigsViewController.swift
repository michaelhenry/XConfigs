import Combine
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
}
