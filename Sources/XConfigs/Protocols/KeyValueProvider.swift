import Foundation

// sourcery: AutoMockable
public protocol KeyValueProvider {
    func provide() async throws -> [String: Any]
}
