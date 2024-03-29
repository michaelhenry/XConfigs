import UIKit
import XConfigs

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let kvProvider = SampleKeyValueProvider()
        XConfigs.configure(with: AppConfigs.self, keyValueProvider: kvProvider, option: .allowInAppModification(.init(store: UserDefaults.standard, updateDelegate: self)))
        kvProvider.download { _ in
            print("is onboarding enabled? \(AppConfigs.shared.isOnboardingEnabled)")
            print("API URL is \(AppConfigs.shared.apiURL)")
            print("API version is \(AppConfigs.shared.apiVersion)")
        }

        return true
    }
}

extension AppDelegate: InAppConfigUpdateDelegate {
    func configWillUpdate(key: String, value: RawStringValueRepresentable, store: KeyValueStore) {
        switch key {
        case "environment":
            store.set(value: "https://\(value.rawString).google.com", for: "apiURL")
        default:
            break
        }
    }
}
