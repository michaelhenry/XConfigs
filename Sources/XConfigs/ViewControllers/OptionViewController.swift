import Combine
import UIKit

final class OptionViewController: UITableViewController {
    struct ViewModel {
        let title: String
        let items: [RawStringValueRepresentable]
    }

    private let viewModel: ViewModel
    private var subscriptions = Set<AnyCancellable>()

    var selectedItemPublisher: AnyPublisher<RawStringValueRepresentable, Never> {
        tableView.didSelectRowPublisher
            .compactMap { [weak self] indexPath -> RawStringValueRepresentable? in
                guard let self = self else { return nil }
                self.dismiss(animated: true)
                return self.viewModel.items[indexPath.item]
            }
            .eraseToAnyPublisher()
    }

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
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = viewModel.items[indexPath.item].rawString
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        dismiss(animated: true)
    }

    private func setupUI() {
        title = viewModel.title
        tableView.registerCell(UITableViewCell.self)

        if #available(iOS 14.0, *) {
            navigationItem.leftBarButtonItem = .init(systemItem: .cancel)
        } else {
            navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: nil)
        }

        navigationItem.leftBarButtonItem?
            .tapPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .store(in: &subscriptions)
    }
}
