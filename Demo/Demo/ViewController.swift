import UIKit
import XConfigs

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
        let vc = XConfigsViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}
