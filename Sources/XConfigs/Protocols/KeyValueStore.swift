import Foundation

public protocol KeyValueStore {
    func get<Value: RawStringValueRepresentable>(for key: String) -> Value?
    func set<Value: RawStringValueRepresentable>(value: Value, for key: String)
    func remove(key: String)
}

public struct EmptyKeyValueStore: KeyValueStore {
    
    public init() {}
    
    public func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        nil
    }
    
    public func set<Value: RawStringValueRepresentable>(value: Value, for key: String) where Value : RawStringValueRepresentable {}
    
    public func remove(key: String) {}
}
