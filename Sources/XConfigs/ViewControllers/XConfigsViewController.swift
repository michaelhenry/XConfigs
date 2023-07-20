#if canImport(UIKit)
    import Combine
    import CombineCocoa
    import UIKit

    final class XConfigsViewController: UITableViewController {
        typealias ViewModel = XConfigsViewModel
        typealias DataSource = TableViewDataSource<ViewModel.Section, ViewModel.Item>

        private let viewModel: ViewModel
        private var subscriptions = Set<AnyCancellable>()
        private var updateValueSubject = PassthroughSubject<KeyValue, Never>()
        private var overrideConfigSubject = PassthroughSubject<Bool, Never>()
        private var resetSubject = PassthroughSubject<Void, Never>()
        private var shouldAnimate = false

        private lazy var datasource: DataSource = {
            var ds = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
                guard let self = self else { return .init() }
                switch item {
                case let .toggle(vm):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
                    cell.configure(with: (vm.displayName, vm.value))
                    cell.mainView.valueChangedPublisher
                        .map { KeyValue(key: vm.key, value: $0) }
                        .subscribe(self.updateValueSubject)
                        .store(in: &cell.subscriptions)
                    cell.selectionStyle = .none
                    return cell
                case let .textInput(vm):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                    cell.configure(with: (vm.displayName, vm.value))
                    return cell
                case let .optionSelection(vm):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                    cell.configure(with: (vm.displayName, vm.value))
                    cell.selectionStyle = .default
                    return cell
                case let .actionButton(title, _):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<ActionView>.self, for: indexPath)
                    cell.configure(with: title)
                    return cell
                case let .inAppModification(title, val):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
                    cell.configure(with: (title, val))
                    cell.mainView.valueChangedPublisher
                        .subscribe(self.overrideConfigSubject)
                        .store(in: &cell.subscriptions)
                    cell.selectionStyle = .none
                    return cell
                case let .nameValue(name, val):
                    let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                    cell.configure(with: (name, val))
                    cell.selectionStyle = .none
                    return cell
                }
            }
            ds.defaultRowAnimation = .fade
            return ds
        }()

        private lazy var searchController = UISearchController(searchResultsController: nil).apply {
            $0.obscuresBackgroundDuringPresentation = false
        }

        init(viewModel: XConfigsViewModel) {
            self.viewModel = viewModel
            if #available(iOS 13.0, *) {
                super.init(style: .insetGrouped)
            } else {
                super.init(style: .grouped)
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
            navigationItem.rightBarButtonItem = doneButton
            setupUI()
            handleViewModelOutput()
        }

        private func setupUI() {
            navigationItem.searchController = searchController
            setupTableView()
        }

        private func setupTableView() {
            tableView.registerCell(UIViewTableWrapperCell<ToggleView>.self)
            tableView.registerCell(UIViewTableWrapperCell<KeyValueView>.self)
            tableView.registerCell(UIViewTableWrapperCell<ActionView>.self)
            if #available(iOS 15.0, *) {
                tableView.isPrefetchingEnabled = false
            }
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            shouldAnimate = true
        }

        private func handleViewModelOutput() {
            guard let doneButton = navigationItem.rightBarButtonItem else { return }
            let output = viewModel.transform(
                input: .init(
                    searchPublisher: searchController.searchBar.textDidChangePublisher.prepend("").eraseToAnyPublisher(),
                    reloadPublisher: Just(()).eraseToAnyPublisher(),
                    updateValuePublisher: updateValueSubject.eraseToAnyPublisher(),
                    overrideConfigPublisher: overrideConfigSubject.eraseToAnyPublisher(),
                    resetPublisher: resetSubject.eraseToAnyPublisher(),
                    selectItemPublisher: tableView.didSelectRowPublisher.compactMap { [weak self] indexPath -> ViewModel.Item? in
                        guard let self = self else { return nil }
                        self.tableView.deselectRow(at: indexPath, animated: false)
                        return self.datasource.itemIdentifier(for: indexPath)
                    }.eraseToAnyPublisher(),
                    dismissPublisher: doneButton.tapPublisher
                ))

            output.searchPlaceholderTitle.compactMap { $0 }.assign(to: \UISearchBar.placeholder, on: searchController.searchBar).store(in: &subscriptions)
            output.title.compactMap { $0 }.assign(to: \UIViewController.title, on: self).store(in: &subscriptions)

            output.sectionItemsModels
                .sink { [weak self] secItems in
                    guard let self = self else { return }
                    self.datasource.apply(secItems.snapshot(), animatingDifferences: self.shouldAnimate)
                }
                .store(in: &subscriptions)

            output.action.sink { [weak self] action in
                self?.handleAction(action)
            }
            .store(in: &subscriptions)
        }

        private func handleAction(_ action: ViewModel.Action) {
            switch action {
            case let .showOptionSelection(model):
                showOptionSelection(for: model)
            case let .showTextInput(model):
                showTextInputViewController(model: model)
            case let .showResetConfirmation(title):
                let alertConfirmation = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alertConfirmation.addAction(.init(title: "Reset", style: .destructive, handler: { [weak self] _ in
                    self?.resetSubject.send(())
                }))
                alertConfirmation.addAction(.init(title: "Cancel", style: .cancel))
                present(alertConfirmation, animated: true)
            case .dismiss:
                dismiss(animated: true)
            }
        }

        private func showTextInputViewController(model: TextInputModel) {
            let textInputVC = InputValueViewController(viewModel: .init(model: model))
            textInputVC.valuePublisher
                .map { KeyValue(key: model.key, value: $0) }
                .subscribe(updateValueSubject)
                .store(in: &subscriptions)
            present(textInputVC.wrapInsideNavVC().preferAsHalfSheet(), animated: true)
        }

        private func showOptionSelection(for model: OptionSelectionModel) {
            let optionVC = OptionViewController(viewModel: .init(model: model))
            optionVC.selectedItemPublisher
                .map { KeyValue(key: model.key, value: $0) }
                .subscribe(updateValueSubject)
                .store(in: &subscriptions)
            present(optionVC.wrapInsideNavVC().preferAsHalfSheet(), animated: true)
        }

        override func tableView(_: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint) -> UIContextMenuConfiguration? {
            guard let item = datasource.itemIdentifier(for: indexPath) else { return nil }
            switch item {
            case let .toggle(vm):
                return createContextMenuConfiguration(title: vm.key, actions: [createCopyAction(vm.key)])
            case let .textInput(vm):
                return createContextMenuConfiguration(title: vm.key, actions: [createCopyAction(vm.key), createCopyAction(vm.value)])
            case let .optionSelection(vm):
                return createContextMenuConfiguration(title: vm.key, actions: [createCopyAction(vm.key), createCopyAction(vm.value)])
            default:
                return nil
            }
        }

        private func createCopyAction(_ value: String) -> UIAction {
            let copyAction = UIAction(title: "Copy \"\(value)\"") { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = value
            }
            return copyAction
        }

        @available(iOS 13.0, *)
        private func createContextMenuConfiguration(title: String, actions: [UIAction]) -> UIContextMenuConfiguration {
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
                UIMenu(title: title, children: actions)
            })
        }
    }
#endif
