import Foundation

public protocol RemoteKeyValueProvider {
    func provide() -> [String: Any]
}
