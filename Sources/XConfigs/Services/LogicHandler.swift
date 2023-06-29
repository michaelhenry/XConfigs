import Foundation

public struct ValueWithPermission<Value> {
    public let readonly: Bool
    public let value: Value

    public init(readonly: Bool, value: Value) {
        self.readonly = readonly
        self.value = value
    }
}

/// A protocol that handles the actual logic for the configuration.
public protocol XConfigsLogicHandler {
    func handle<Value: RawStringValueRepresentable>(isInAppModificationEnabled: Bool, key: String, defaultValue: Value, group: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> ValueWithPermission<Value>
}

public struct OverrideFromRemoteLogicHandler: XConfigsLogicHandler {
    public init() {}

    public func handle<Value: RawStringValueRepresentable>(isInAppModificationEnabled: Bool, key: String, defaultValue: Value, group _: XConfigGroup, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore?) -> ValueWithPermission<Value> {
        guard isInAppModificationEnabled else { return .init(readonly: true, value: keyValueProvider.get(for: key) ?? defaultValue) }
        return .init(readonly: false, value: keyValueStore?.get(for: key) ?? keyValueProvider.get(for: key) ?? defaultValue)
    }
}
