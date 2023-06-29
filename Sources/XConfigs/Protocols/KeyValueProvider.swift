import Foundation

/// A protocol for providing key value.
public protocol KeyValueProvider {
    func get<Value: RawStringValueRepresentable>(for key: String) -> Value?
}
