import UIKit
import XConfigs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let kvProvider = SampleKeyValueProvider()
        XConfigs.configure(with: AppConfigs.self, keyValueProvider: kvProvider, option: .allowInAppModification(.init(store: UserDefaults.standard)))
        kvProvider.download { _ in
            print("is onboarding enabled? \(AppConfigs.shared.isOnboardingEnabled)")
            print("API URL is \(AppConfigs.shared.apiURL)")
            print("API version is \(AppConfigs.shared.apiVersion)")
        }

        return true
    }
}
