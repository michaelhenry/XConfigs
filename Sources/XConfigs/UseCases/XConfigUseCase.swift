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

    private let keyValueStore: KeyValueStore
    private let keyValueProvider: KeyValueProvider
    private let configsSpec: XConfigsSpec.Type
    private let logicHandler: LogicHandler

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    init(spec: XConfigsSpec.Type, keyValueProvider: KeyValueProvider, keyValueStore: KeyValueStore, logicHandler: LogicHandler = OverrideFromRemoteLogicHandler()) {
        configsSpec = spec
        self.keyValueProvider = keyValueProvider
        self.keyValueStore = keyValueStore
        self.logicHandler = logicHandler
    }

    func getConfigs() -> [ConfigInfo] {
        guard isOverriden else { return [] }
        let instance = configsSpec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    func get<Value: RawStringValueRepresentable>(for key: String, defaultValue: Value, group: XConfigGroup) -> Value {
        logicHandler.handle(isOverriden: isOverriden, key: key, defaultValue: defaultValue, keyValueStore: keyValueStore, keyValueProvider: keyValueProvider, group: group)
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
