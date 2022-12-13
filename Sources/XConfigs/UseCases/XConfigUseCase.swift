import Foundation

public class XConfigUseCase {
    private let isOverridenKey = "XConfigs.Debug.isOverriden"

    var isOverriden: Bool {
        get {
            keyValueStore.get(for: isOverridenKey) ?? false
        }

        set {
            keyValueStore.set(value: newValue, for: isOverridenKey)
        }
    }

    private var keyValueStore: KeyValueStore
    private var keyValueProvider: KeyValueProvider
    private var configsSpec: XConfigsSpec.Type

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    init(spec: XConfigsSpec.Type, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore) {
        configsSpec = spec
        self.keyValueProvider = keyValueProvider
        self.keyValueStore = keyValueStore
    }

    func getConfigs() -> [ConfigInfo] {
        guard isOverriden else { return [] }
        let instance = configsSpec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    func get<Value: RawStringValueRepresentable>(for key: String, defaultValue: Value) -> Value {
        guard isOverriden else { return keyValueProvider.get(for: key) ?? defaultValue }
        return keyValueStore.get(for: key) ?? keyValueProvider.get(for: key) ?? defaultValue
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        guard isOverriden else { return }
        keyValueStore.set(value: value, for: key)
    }

    func reset() {
        guard isOverriden else { return }
        getConfigs().forEach {
            keyValueStore.remove(key: $0.configKey)
        }
    }
}
