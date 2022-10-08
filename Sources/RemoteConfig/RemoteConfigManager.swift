import Foundation

class RemoteConfigManager {
    static let manager = RemoteConfigManager()
    var valueProvider: RemoteConfigValueProvider = UserDefaults.standard
}
