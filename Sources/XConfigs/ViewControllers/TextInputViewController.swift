import Combine
import CombineCocoa
import UIKit

final class TextInputViewController: UIViewController {
    struct ViewModel {
        let title: String
        let value: String
    }

    private lazy var textView = UITextView().apply {
        $0.font = .preferredFont(forTextStyle: .body)
    }

    private let viewModel: ViewModel
    private var subscriptions = Set<AnyCancellable>()

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

        navigationItem.rightBarButtonItem?
            .tapPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .store(in: &subscriptions)
    }

    private func setupUI() {
        title = viewModel.title
        textView.text = viewModel.value

        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItem = .init(systemItem: .done)
        } else {
            navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: nil)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 20),
            view.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
        ])
        textView.becomeFirstResponder()
    }
}
