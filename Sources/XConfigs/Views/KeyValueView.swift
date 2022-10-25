import UIKit

final class KeyValueView: UIView, ConfigurableView {
    typealias ViewModel = (String, String)

    private let keyLabel = UILabel()

    private let valueLabel = UILabel().apply {
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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
        stackview.bindToSuperview(margins: .init(top: 10, left: 20, bottom: 10, right: 20))
    }
}
