import Foundation

protocol LogicHandler {
    func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, keyValueStore: KeyValueStore, keyValueProvider: KeyValueProvider, group: XConfigGroup) -> Value
}

struct OverrideFromRemoteLogicHandler: LogicHandler {
    func handle<Value: RawStringValueRepresentable>(isOverriden: Bool, key: String, defaultValue: Value, keyValueStore: KeyValueStore, keyValueProvider: KeyValueProvider, group _: XConfigGroup) -> Value {
        guard isOverriden else { return keyValueProvider.get(for: key) ?? defaultValue }
        return keyValueStore.get(for: key) ?? keyValueProvider.get(for: key) ?? defaultValue
    }
}
