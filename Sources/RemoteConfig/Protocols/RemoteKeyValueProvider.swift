import Foundation

protocol RemoteKeyValueProvider {
    func provide() async -> [String: Any]
}
