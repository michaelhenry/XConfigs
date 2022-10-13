import UIKit
import XConfig

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let btn = UIButton(type: .custom)
        view.addSubview(btn)
        btn.setTitle("Tap me", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.topAnchor),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        btn.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    @objc func didTap() {
        let vc = XConfigsViewController(viewModel: .init(spec: FeatureFlags.self))
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

struct FeatureFlags: XConfigSpec {
    static let `default` = Self()

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiHost", defaultValue: "https://google.com")
    var apiHost: String

    @XConfig(key: "region", defaultValue: .north)
    var region: Region

    @XConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @XConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @XConfig(key: "rate", defaultValue: 2.5)
    var rate: Double
}

enum Region: String, CaseIterable, RawStringRepresentable {
    case north
    case south
    case east
    case west

    init(rawString: String) {
        self = .init(rawValue: rawString) ?? .north
    }

    var rawString: String {
        rawValue
    }
}
