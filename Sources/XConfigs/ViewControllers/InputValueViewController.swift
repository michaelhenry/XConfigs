import Combine
import CombineCocoa
import UIKit

struct InputValueViewModel: ViewModelType {
    let title: String
    let value: String

    typealias Input = Void
    typealias Output = Void

    func transform(input _: Void) {}
}

final class InputValueViewController: UIViewController {
    typealias ViewModel = InputValueViewModel

    private lazy var textView = UITextView().apply {
        $0.font = .preferredFont(forTextStyle: .body)
    }

    private let viewModel: ViewModel
    private var subscriptions = Set<AnyCancellable>()

    private var textSubject = PassthroughSubject<String, Never>()

    var valuePublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
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

    private func setupUI() {
        title = viewModel.title
        textView.text = viewModel.value

        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItem = .init(systemItem: .done)
            navigationItem.leftBarButtonItem = .init(systemItem: .cancel)
        } else {
            navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: nil)
            navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: nil)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        textView.bindToSuperview(margins: 20)

        navigationItem.leftBarButtonItem?
            .tapPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .store(in: &subscriptions)

        navigationItem.rightBarButtonItem?
            .tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.textSubject.send(self.textView.text)
                self.dismiss(animated: true)
            })
            .store(in: &subscriptions)
    }
}
