import RxCocoa
import RxSwift
import UIKit

final class OptionViewController: UITableViewController {
    typealias ViewModel = OptionViewModel
    typealias DataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

    private let viewModel: ViewModel
    private var disposeBag = DisposeBag()

    private let itemSubject = PublishSubject<String>()
    var selectedItemPublisher: Observable<String> {
        itemSubject
    }

    private lazy var datasource: DataSource = {
        var ds = DataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let self = self else { return .init() }
            let cell = tableView.dequeueCell(UITableViewCell.self, for: indexPath)
            cell.textLabel?.text = item.displayName
            return cell
        }
        ds.defaultRowAnimation = .fade
        return ds
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleViewModelOutput()
    }

    private func handleViewModelOutput() {
        guard let leftNavItem = navigationItem.leftBarButtonItem else { return }
        let output = viewModel.transform(input: .init(
            reloadPublisher: .just(()),
            dismissPublisher: leftNavItem.rx.tap.map { _ in () }.asObservable(),
            selectItemPublisher: tableView.rx.itemSelected.compactMap { [weak self] indexPath -> ViewModel.Item? in
                guard let self = self else { return nil }
                return self.datasource.itemIdentifier(for: indexPath)
            }
        ))

        output.title.drive(onNext: { [weak self] title in
            self?.title = title
        })
        .disposed(by: disposeBag)

        output.sectionItemsModels
            .drive(onNext: { [weak self] secItems in
                guard let self = self else { return }
                self.datasource.apply(secItems.snapshot(), animatingDifferences: false)
            })
            .disposed(by: disposeBag)

        output.action
            .drive(onNext: { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .cancel:
                    self.dismiss(animated: true)
                case let .select(item):
                    self.itemSubject.onNext(item.value)
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        dismiss(animated: true)
    }

    private func setupUI() {
        tableView.registerCell(UITableViewCell.self)

        if #available(iOS 14.0, *) {
            navigationItem.leftBarButtonItem = .init(systemItem: .cancel)
        } else {
            navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: nil)
        }
    }
}
