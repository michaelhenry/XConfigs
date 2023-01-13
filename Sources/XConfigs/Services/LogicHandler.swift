import Foundation

public protocol XConfigsLogicHandler {
    func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, group: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> Value
}

public struct OverrideFromRemoteLogicHandler: XConfigsLogicHandler {
    public init() {}

    public func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, group _: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> Value {
        guard isOverriden else { return keyValueProvider.get(for: key) ?? defaultValue }
        return keyValueStore?.get(for: key) ?? keyValueProvider.get(for: key) ?? defaultValue
    }
}