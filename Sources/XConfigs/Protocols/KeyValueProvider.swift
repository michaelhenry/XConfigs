import Foundation

// sourcery: AutoMockable
public protocol KeyValueProvider {
    func get<Value: RawStringValueRepresentable>(for key: String) -> Value?
}
