import Foundation

public protocol RemoteKeyValueProvider {
    func provide() -> [String: Any]

    func get<Value>(for key: String) -> Value?
}
