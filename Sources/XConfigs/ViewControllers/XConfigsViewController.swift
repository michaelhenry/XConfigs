import RxSwift
import UIKit

final class XConfigsViewController: UITableViewController {
    typealias ViewModel = XConfigsViewModel
    typealias DataSource = AnyDiffableDataSource<ViewModel.Section, ViewModel.Item>

    private let viewModel: ViewModel
    private var disposeBag = DisposeBag()
    private var updateValueSubject = PublishSubject<KeyValue>()
    private var overrideConfigSubject = PublishSubject<Bool>()
    private var resetSubject = PublishSubject<Void>()
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
                    .bind(to: self.updateValueSubject)
                    .disposed(by: cell.disposeBag)
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
                    .bind(to: self.overrideConfigSubject)
                    .disposed(by: cell.disposeBag)
                cell.selectionStyle = .none
                return cell
            case let .nameValue(name, val):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                cell.configure(with: (name, val))
                cell.selectionStyle = .none
                return cell
            }
        }
        return ds
    }()

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
        setupTableView()
        handleViewModelOutput()
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
                reloadPublisher: .just(()),
                updateValuePublisher: updateValueSubject,
                overrideConfigPublisher: overrideConfigSubject,
                resetPublisher: resetSubject,
                selectItemPublisher: tableView.rx.itemSelected.compactMap { [weak self] indexPath -> ViewModel.Item? in
                    guard let self = self else { return nil }
                    self.tableView.deselectRow(at: indexPath, animated: false)
                    return self.datasource.itemIdentifier(for: indexPath)
                },
                dismissPublisher: doneButton.rx.tap.map { _ in () }
            ))

        output.sectionItemsModels
            .drive(onNext: { [weak self] secItems in
                guard let self else { return }
                self.datasource.applyAnySnapshot(secItems.anySnapshot(), animatingDifferences: self.shouldAnimate)
            })
            .disposed(by: disposeBag)

        output.title.drive(onNext: { [weak self] title in
            self?.title = title
        })
        .disposed(by: disposeBag)

        output.action.drive(onNext: { [weak self] action in
            self?.handleAction(action)
        })
        .disposed(by: disposeBag)
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
                self?.resetSubject.onNext(())
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
            .bind(to: updateValueSubject)
            .disposed(by: disposeBag)
        present(textInputVC.wrapInsideNavVC().preferAsHalfSheet(), animated: true)
    }

    private func showOptionSelection(for model: OptionSelectionModel) {
        let optionVC = OptionViewController(viewModel: .init(model: model))
        optionVC.selectedItemPublisher
            .map { KeyValue(key: model.key, value: $0) }
            .bind(to: updateValueSubject)
            .disposed(by: disposeBag)
        present(optionVC.wrapInsideNavVC().preferAsHalfSheet(), animated: true)
    }

    @available(iOS 13.0, *)
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

    @available(iOS 13.0, *)
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
