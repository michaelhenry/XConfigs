import Combine
import CombineCocoa
import UIKit

public final class XConfigsViewController: UITableViewController {
    typealias ViewModel = XConfigsViewModel
    typealias DataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

    private let viewModel: ViewModel
    private var subscriptions = Set<AnyCancellable>()
    private var updateValueSubject = PassthroughSubject<KeyValue, Never>()
    private var shouldAnimate = false

    private lazy var datasource: DataSource = {
        var ds = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let self = self else { return .init() }
            switch item {
            case let .toggle(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                cell.mainView.valueChangedPublisher
                    .map { KeyValue(key: vm.key, value: $0) }
                    .subscribe(self.updateValueSubject)
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
        ds.defaultRowAnimation = .fade
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

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldAnimate = true
    }

    private func handleViewModelOutput() {
        let output = viewModel.transform(
            input: .init(
                reloadPublisher: Just(()).eraseToAnyPublisher(),
                updateValuePublisher: updateValueSubject.eraseToAnyPublisher()
            ))

        output.sectionItemsModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] secItems in
                guard let self = self else { return }
                self.datasource.apply(secItems.snapshot(), animatingDifferences: self.shouldAnimate)
            }
            .store(in: &subscriptions)
    }

    private func handleItemSelection(_ indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
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
        let textInputVC = InputValueViewController(viewModel: .init(title: model.key, value: model.value))

        textInputVC.valuePublisher
            .map { KeyValue(key: model.key, value: $0) }
            .subscribe(updateValueSubject)
            .store(in: &subscriptions)

        let nvc = textInputVC.wrapInsideNavVC()

        // Sheet
        nvc.preferAsHalfSheet()
        present(nvc, animated: true)
    }

    func showOptionSelection(for model: OptionSelectionModel) {
        let optionVC = OptionViewController(viewModel: .init(choices: model.choices, selectedItem: model.value))

        optionVC.selectedItemPublisher
            .map { KeyValue(key: model.key, value: $0) }
            .subscribe(updateValueSubject)
            .store(in: &subscriptions)

        let nvc = optionVC.wrapInsideNavVC()

        // Sheet
        nvc.preferAsHalfSheet()
        present(nvc, animated: true)
    }
}
