import Combine
import Foundation

public class XConfigUseCase {
    private let isOverridenKey = "XConfigs.Debug.isOverriden"

    var isOverriden: Bool {
        get {
            developmentKvStore.get(for: isOverridenKey) ?? false
        }

        set {
            developmentKvStore.set(value: newValue, for: isOverridenKey)
        }
    }

    private var developmentKvStore: KeyValueStore
    private var remoteKVProvider: KeyValueProvider
    private var configsSpec: XConfigsSpec.Type

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    init(spec: XConfigsSpec.Type, remoteKVProvider: KeyValueProvider, developmentKvStore: KeyValueStore) {
        configsSpec = spec
        self.remoteKVProvider = remoteKVProvider
        self.developmentKvStore = developmentKvStore
    }

    func getConfigs() -> [ConfigInfo] {
        guard isOverriden else { return [] }
        let instance = configsSpec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard isOverriden else { return remoteKVProvider.get(for: key) }
        return developmentKvStore.get(for: key) ?? remoteKVProvider.get(for: key)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        guard isOverriden else { return }
        developmentKvStore.set(value: value, for: key)
    }

    func reset() {
        guard isOverriden else { return }
        getConfigs().forEach {
            developmentKvStore.remove(key: $0.configKey)
        }
    }
}
