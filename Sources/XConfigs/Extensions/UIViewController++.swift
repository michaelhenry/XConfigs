import UIKit

extension UIViewController {
    func preferAsHalfSheet() -> UIViewController {
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//                sheet.prefersGrabberVisible = true // UIKit bug causing to retain
                sheet.preferredCornerRadius = 10
            }
        }
        return self
    }

    func wrapInsideNavVC() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }
}
