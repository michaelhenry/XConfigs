#if canImport(UIKit)
import UIKit

extension UIViewController {
    func preferAsHalfSheet(preferredCornerRadius: CGFloat = 10) -> UIViewController {
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = preferredCornerRadius
            }
        }
        return self
    }

    func wrapInsideNavVC() -> UINavigationController {
        UINavigationController(rootViewController: self)
    }
}
#endif
