import CombineCocoa
import UIKit

final class ToggleView: UIView, ConfigurableView {
    typealias ViewModel = (String, Bool)

    let switchView = UISwitch()
    private let keyLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupUI() {
        let stackview = UIStackView(arrangedSubviews: [
            keyLabel,
            switchView,
        ])
        addSubview(stackview)
        stackview.bindToSuperview(margins: .init(top: 10, left: 20, bottom: 10, right: 20))
    }

    // MARK: - Internal

    func configure(with viewModel: ViewModel) {
        keyLabel.text = viewModel.0
        switchView.isOn = viewModel.1
    }
}
