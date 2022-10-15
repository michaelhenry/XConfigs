import Combine
import Foundation

public class XConfigUseCase {
    public static let shared = XConfigUseCase()

    var isOverriden: Bool = true
    var kvStore: (() -> KeyValueStore)?
    var remoteKVProvider: (() -> RemoteKeyValueProvider)?
    var configsSpec: (() -> XConfigsSpec.Type)?

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    private init() {}

    func getConfigs() -> [ConfigInfo] {
        guard let spec = configsSpec?() else { fatalError("Must set the config spec") }
        let instance = spec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    public func set(configsSpec: @escaping (() -> XConfigsSpec.Type)) {
        self.configsSpec = configsSpec
    }

    public func set(kvStore: @escaping (() -> KeyValueStore)) {
        self.kvStore = kvStore
    }

    public func set(remoteKVProvider: @escaping (() -> RemoteKeyValueProvider)) {
        self.remoteKVProvider = remoteKVProvider
    }

    public func downloadLatest() {
        _ = remoteKVProvider?().provide()
    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard isOverriden else { return remoteKVProvider?().get(for: key) }
        return kvStore?().get(for: key)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        guard isOverriden else { return }
        kvStore?().set(value: value, for: key)
    }

    func resetLocalValues() {
        guard isOverriden else { return }
        //        localKVStore?().deleteAll()
    }
}

class InMemoryKVStore: KeyValueStore {
    static let shared = InMemoryKVStore()

    private var kv: [String: RawStringValueRepresentable] = [:]

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawString = kv[key]?.rawString else { return nil }
        return Value(rawString: rawString)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        kv[key] = value
    }
}
