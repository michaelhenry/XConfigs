import Foundation

protocol RemoteConfigValueProvider {
    func get<Value>(key: String) -> Value?
}
