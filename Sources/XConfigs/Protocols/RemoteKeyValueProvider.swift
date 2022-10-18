import Foundation

public protocol RemoteKeyValueProvider {
    func provide() async throws -> [String: Any]
}
