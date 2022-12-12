import Highlightr
import RxSwift
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
    private var disposeBag = DisposeBag()

    private var textSubject = PublishSubject<String>()

    var valuePublisher: Observable<String> {
        textSubject
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
            textPublisher: textView.rx.text.compactMap { $0 }.asObservable(),
            dismissPublisher: leftNavItem.rx.tap.asObservable(),
            donePublisher: rightNavITem.rx.tap.asObservable()
        ))
        output.title.drive(onNext: { [weak self] title in
            self?.title = title
        })
        .disposed(by: disposeBag)

        output.value.drive(onNext: { [weak self] value in
            self?.textView.text = value
        })
        .disposed(by: disposeBag)

        output.action.drive(onNext: { [weak self] action in
            switch action {
            case .cancel:
                self?.dismiss(animated: true)
            case let .done(text):
                self?.textSubject.onNext(text)
                self?.dismiss(animated: true)
            }
        })
        .disposed(by: disposeBag)
    }
}
