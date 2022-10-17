import UIKit

final class ActionView: UIView, ConfigurableView {
    typealias ViewModel = String

    private let keyLabel = UILabel().apply {
        $0.textColor = .link
    }

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ViewModel) {
        keyLabel.text = viewModel
    }

    private func setupUI() {
        addSubview(keyLabel)
        keyLabel.bindToSuperview(margins: .init(top: 10, left: 20, bottom: 10, right: 20))
    }
}
