import UIKit

final class KeyValueView: UIView, ConfigurableView {
    typealias ViewModel = (String, String)

    private let keyLabel = UILabel().apply {
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private let valueLabel = UILabel().apply {
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        $0.textAlignment = .right
        $0.widthAnchor.constraint(lessThanOrEqualToConstant: 160).isActive = true
        $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 31).isActive = true
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
        keyLabel.text = viewModel.0
        valueLabel.text = viewModel.1
        keyLabel.layoutIfNeeded()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        let stackview = UIStackView(arrangedSubviews: [
            keyLabel,
            valueLabel,
        ]).apply {
            $0.spacing = 10
        }
        addSubview(stackview)
        stackview.bindToSuperview(margins: .init(top: 7, left: 20, bottom: 7, right: 20))
    }
}
