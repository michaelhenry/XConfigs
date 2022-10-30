import Combine
import CombineCocoa
import Highlightr
import UIKit

final class InputValueViewController: UIViewController, UITextViewDelegate {
    typealias ViewModel = InputValueViewModel

    private lazy var textContainer = NSTextContainer().apply {
        let textStorage = CodeAttributedString()
        textStorage.language = "Javascript"
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer($0)
        textStorage.highlightr.setTheme(to: "vs")
    }

    private lazy var textView = UITextView(frame: .zero, textContainer: textContainer).apply {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.isEditable = true
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
        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItem = .init(systemItem: .done)
            navigationItem.leftBarButtonItem = .init(systemItem: .cancel)
        } else {
            navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: nil)
            navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: nil)
        }
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        textView.bindToSuperview(margins: .init(top: 20, left: 20, bottom: 20, right: 5))
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
        output.title.sink { [weak self] title in
            self?.title = title
        }
        .store(in: &subscriptions)

        output.value.sink { [weak self] value in
            self?.textView.text = value
        }
        .store(in: &subscriptions)

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
