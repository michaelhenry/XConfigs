#if canImport(UIKit)
    import Combine
    import UIKit

    final class OptionViewController: UITableViewController {
        typealias ViewModel = OptionViewModel
        typealias DataSource = UITableViewDiffableDataSource<ViewModel.Section, ViewModel.Item>

        private let viewModel: ViewModel
        private var subscriptions = Set<AnyCancellable>()

        private let itemSubject = PassthroughSubject<String, Never>()
        var selectedItemPublisher: AnyPublisher<String, Never> {
            itemSubject.eraseToAnyPublisher()
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
                reloadPublisher: Just(()).eraseToAnyPublisher(),
                dismissPublisher: leftNavItem.tapPublisher,
                selectItemPublisher: tableView.didSelectRowPublisher.compactMap { [weak self] indexPath -> ViewModel.Item? in
                    guard let self = self else { return nil }
                    return self.datasource.itemIdentifier(for: indexPath)
                }.eraseToAnyPublisher()
            ))

            output.title.sink { [weak self] title in
                self?.title = title
            }
            .store(in: &subscriptions)

            output.sectionItemsModels
                .sink { [weak self] secItems in
                    guard let self = self else { return }
                    self.datasource.apply(secItems.snapshot(), animatingDifferences: false)
                }
                .store(in: &subscriptions)

            output.action
                .sink { [weak self] action in
                    guard let self = self else { return }
                    switch action {
                    case .cancel:
                        self.dismiss(animated: true)
                    case let .select(item):
                        self.itemSubject.send(item.value)
                        self.dismiss(animated: true)
                    }
                }
                .store(in: &subscriptions)
        }

        override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
            dismiss(animated: true)
        }

        private func setupUI() {
            tableView.registerCell(UITableViewCell.self)
            navigationItem.leftBarButtonItem = .init(systemItem: .cancel)
        }
    }
#endif
