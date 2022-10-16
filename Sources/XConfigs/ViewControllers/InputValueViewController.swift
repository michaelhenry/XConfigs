import Combine
import CombineCocoa
import UIKit

struct InputValueViewModel: ViewModelType {
    let title: String
    let value: String

    struct Input {
        let textPublisher: AnyPublisher<String, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
        let donePublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let action: AnyPublisher<Action, Never>
    }

    enum Action {
        case cancel
        case done(String)
    }

    func transform(input: Input) -> Output {
        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let doneAction = input.donePublisher.withLatestFrom(input.textPublisher).map(Action.done)
        let action = Publishers.Merge(cancelAction, doneAction).eraseToAnyPublisher()
        return .init(action: action)
    }
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
        handleViewModelOutput()
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
    }

    private func handleViewModelOutput() {
        guard let leftNavItem = navigationItem.leftBarButtonItem,
              let rightNavITem = navigationItem.rightBarButtonItem
        else { return }
        let output = viewModel.transform(input: .init(
            textPublisher: textView.textPublisher.compactMap { $0 }.eraseToAnyPublisher(),
            dismissPublisher: leftNavItem.tapPublisher,
            donePublisher: rightNavITem.tapPublisher
        ))
        output.action.sink { [weak self] action in
            switch action {
            case .cancel:
                self?.dismiss(animated: true)
            case let .done(text):
                self?.textSubject.send(text)
                self?.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)
    }
}
