import RxCocoa
import RxSwift
import UIKit

final class XConfigsViewController: UITableViewController {
    typealias ViewModel = XConfigsViewModel
    typealias DataSource = TableViewDataSource<ViewModel.Section, ViewModel.Item>

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
                cell.configure(with: (vm.key, vm.value))
                cell.mainView.valueChangedPublisher
                    .map { KeyValue(key: vm.key, value: $0) }
                    .bind(to: self.updateValueSubject)
                    .disposed(by: cell.disposeBag)
                cell.selectionStyle = .none
                return cell
            case let .textInput(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                return cell
            case let .optionSelection(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<KeyValueView>.self, for: indexPath)
                cell.configure(with: (vm.key, vm.value))
                return cell
            case let .action(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<ActionView>.self, for: indexPath)
                cell.configure(with: vm)
                return cell
            case let .overrideConfig(vm):
                let cell = tableView.dequeueCell(UIViewTableWrapperCell<ToggleView>.self, for: indexPath)
                cell.configure(with: ("Override", vm))
                cell.mainView.valueChangedPublisher
                    .bind(to: self.overrideConfigSubject)
                    .disposed(by: cell.disposeBag)
                cell.selectionStyle = .none
                return cell
            }
        }
        ds.defaultRowAnimation = .fade
        return ds
    }()

    init(viewModel: XConfigsViewModel) {
        self.viewModel = viewModel
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerCell(UIViewTableWrapperCell<ToggleView>.self)
        tableView.registerCell(UIViewTableWrapperCell<KeyValueView>.self)
        tableView.registerCell(UIViewTableWrapperCell<ActionView>.self)
        handleViewModelOutput()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleItemSelection(indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldAnimate = true
    }

    private func handleViewModelOutput() {
        let output = viewModel.transform(
            input: .init(
                reloadPublisher: .just(()),
                updateValuePublisher: updateValueSubject,
                overrideConfigPublisher: overrideConfigSubject,
                resetPublisher: resetSubject
            ))

        output.sectionItemsModels
            .drive(onNext: { [weak self] secItems in
                guard let self = self else { return }
                self.datasource.apply(secItems.snapshot(), animatingDifferences: self.shouldAnimate)
            })
            .disposed(by: disposeBag)

        output.title.drive(onNext: { [weak self] title in
            self?.title = title
        })
        .disposed(by: disposeBag)
    }

    private func handleItemSelection(_ indexPath: IndexPath) {
        guard let item = datasource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case let .optionSelection(model):
            showOptionSelection(for: model)
        case let .textInput(model):
            showTextInputViewController(model: model)
        case .action:
            resetSubject.onNext(())
        default:
            break
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
}
