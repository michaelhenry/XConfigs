import UIKit

final class OptionView: UIView, ConfigurableView {
    typealias ViewModel = (String, String?)

    private let keyLabel = UILabel()
    private let valueLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ViewModel) {
        keyLabel.text = viewModel.0
        valueLabel.text = viewModel.1
    }

    private func setupUI() {
        let stackview = UIStackView(arrangedSubviews: [
            keyLabel,
            valueLabel,
        ])
        addSubview(stackview)
        stackview.bindToSuperview(margins: .init(top: 10, left: 20, bottom: 10, right: 20))
    }
}
