import Foundation
import SnapshotTesting
import UIKit

extension Snapshotting where Value: UIViewController, Format == UIImage {
    static func windowsImageWithAction(precision: Float = 0.95, action: @escaping () -> Void) -> Snapshotting {
        Snapshotting<UIImage, UIImage>.image(precision: precision).asyncPullback { vc in
            Async<UIImage> { callback in
                UIView.setAnimationsEnabled(false)
                let window = UIApplication.shared.windows[0]
                window.rootViewController = vc
                action()
                DispatchQueue.main.async {
                    let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
                    }
                    callback(image)
                    UIView.setAnimationsEnabled(true)
                }
            }
        }
    }
}
