import Foundation

// sourcery: AutoMockable
public protocol KeyValueProvider {
    func get<Value>(for key: String) -> Value?
}
