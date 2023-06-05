#if canImport(UIKit)
    import RxCocoa
    import RxSwift
    import UIKit

    final class ToggleView: UIView, ConfigurableView {
        typealias ViewModel = (String, Bool)

        private let switchView = UISwitch()
        private let keyLabel = UILabel().apply {
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.numberOfLines = 0
        }

        var valueChangedPublisher: Observable<Bool> {
            switchView.rx.controlEvent(.valueChanged).map { self.switchView.isOn }
        }

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
            translatesAutoresizingMaskIntoConstraints = false
            let stackview = UIStackView(arrangedSubviews: [
                keyLabel,
                switchView,
            ]).apply {
                $0.distribution = .fill
                $0.spacing = 10
                $0.alignment = .center
            }
            addSubview(stackview)
            stackview.bindToSuperview(margins: .init(top: 7, left: 20, bottom: 7, right: 20))
        }

        // MARK: - Internal

        func configure(with viewModel: ViewModel) {
            keyLabel.text = viewModel.0
            switchView.isOn = viewModel.1
            keyLabel.layoutIfNeeded()
        }
    }
#endif
