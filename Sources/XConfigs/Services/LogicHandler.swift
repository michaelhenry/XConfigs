import Foundation

public struct ValueWithPermission<Value> {
    public let readonly: Bool
    public let value: Value

    public init(readonly: Bool, value: Value) {
        self.readonly = readonly
        self.value = value
    }
}

public protocol XConfigsLogicHandler {
    func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, group: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> ValueWithPermission<Value>
}

public struct OverrideFromRemoteLogicHandler: XConfigsLogicHandler {
    public init() {}

    public func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, group _: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> ValueWithPermission<Value> {
        guard isOverriden else { return .init(readonly: true, value: keyValueProvider.get(for: key) ?? defaultValue) }
        return .init(readonly: false, value: keyValueStore?.get(for: key) ?? keyValueProvider.get(for: key) ?? defaultValue)
    }
}
