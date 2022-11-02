import Foundation

public protocol KeyValueProvider {
    func get<Value: RawStringValueRepresentable>(for key: String) -> Value?
}
