import UIKit

extension UIViewController {
    func preferAsHalfSheet() {
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 10
            }
        }
    }

    func wrapInsideNavVC() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }
}
