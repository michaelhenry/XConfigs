import Foundation

protocol RemoteKeyValueProvider {
    func provide() -> [String: Any]
}
