import UIKit
import XConfigs

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let kvProvider = SampleKeyValueProvider()
        XConfigs.configure(with: AppConfigs.self, keyValueProvider: kvProvider, keyValueStore: UserDefaults.standard)
        kvProvider.download { _ in
            print("is onboarding enabled? \(AppConfigs.shared.isOnboardingEnabled)")
            print("API URL is \(AppConfigs.shared.apiURL)")
            print("API version is \(AppConfigs.shared.apiVersion)")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
