import Foundation

public protocol KeyValueProvider {
    func provide() async throws -> [String: Any]
}
