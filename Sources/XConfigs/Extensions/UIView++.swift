import UIKit

// Provide a default `reuseIdentifier` equal to the class name.
private extension UITableViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableView {
    func registerCell<Cell: UITableViewCell>(_ type: Cell.Type) {
        register(type, forCellReuseIdentifier: type.reuseIdentifier)
    }

    // MARK: Dequeue Table View Cell

    func dequeueCell<Cell: UITableViewCell>(_ type: Cell.Type, for _: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: type.reuseIdentifier) as? Cell else {
            fatalError("Unregistered cell: \(type.reuseIdentifier)")
        }
        return cell
    }
}

extension UIView {
    func bind(to view: UIView, margins: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: margins.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margins.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margins.right),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margins.bottom),
        ])
    }

    func bindToSuperview(margins: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        bind(to: superview, margins: margins)
    }
}

protocol ConfigurableView: UIView {
    associatedtype ViewModel

    func configure(with viewModel: ViewModel)
}

final class UIViewTableWrapperCell<View: ConfigurableView>: UITableViewCell {
    private let view: View

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        view = View()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: View.ViewModel) {
        view.configure(with: viewModel)
    }

    private func setupUI() {
        contentView.addSubview(view)
        view.bindToSuperview()
    }
}
