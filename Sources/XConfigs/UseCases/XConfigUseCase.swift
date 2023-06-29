import Foundation

public class XConfigUseCase {
    private let isInAppModificationEnabledKey = "XConfigs.Debug.isInAppModificationEnabled"

    /// Determine if the in-app modification is enabled.
    var isInAppModificationEnabled: Bool {
        get {
            keyValueStore?.get(for: isInAppModificationEnabledKey) ?? false
        }

        set {
            keyValueStore?.set(value: newValue, for: isInAppModificationEnabledKey)
        }
    }

    private(set) var keyValueStore: KeyValueStore?
    private let keyValueProvider: KeyValueProvider
    private let configsSpec: XConfigsSpec.Type
    private let logicHandler: XConfigsLogicHandler
    private let updateDelegate: InAppConfigUpdateDelegate?

    /// To update the local kv store and remote kv provider, please use the assigned method for it.
    init(spec: XConfigsSpec.Type, keyValueProvider: KeyValueProvider, logicHandler: XConfigsLogicHandler, keyValueStore: KeyValueStore?, updateDelegate: InAppConfigUpdateDelegate?) {
        configsSpec = spec
        self.keyValueProvider = keyValueProvider
        self.keyValueStore = keyValueStore
        self.logicHandler = logicHandler
        self.updateDelegate = updateDelegate
    }

    /// Get the information from the ConfigSpec.
    func getConfigs() -> [ConfigInfo] {
        let instance = configsSpec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    /// Get the Value of a particular key.
    func get<Value: RawStringValueRepresentable>(for key: String, defaultValue: Value, group: XConfigGroup) -> ValueWithPermission<Value> {
        logicHandler.handle(isInAppModificationEnabled: isInAppModificationEnabled, key: key, defaultValue: defaultValue, group: group, keyValueProvider: keyValueProvider, keyValueStore: keyValueStore)
    }

    /// Set the Value of a particular key.
    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        guard isInAppModificationEnabled, let store = keyValueStore else { return }
        updateDelegate?.configWillUpdate(key: key, value: value, store: store)
        keyValueStore?.set(value: value, for: key)
    }

    /// Reset the store (needed for the in-app modification).
    func reset() {
        guard isInAppModificationEnabled else { return }
        getConfigs().forEach {
            keyValueStore?.remove(key: $0.configKey)
        }
    }
}
