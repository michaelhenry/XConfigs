import Foundation

extension UserDefaults: RemoteConfigValueProvider {
    func get<Value>(key: String) -> Value? {
        object(forKey: key) as? Value
    }
}
