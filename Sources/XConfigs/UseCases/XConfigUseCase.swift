import Combine
import Foundation

public class XConfigUseCase {
    public static let shared = XConfigUseCase()

    var isOverriden: Bool = false
    var configStore: (() -> ConfigStoreProtocol)?
    var remoteKVProvider: (() -> RemoteKeyValueProvider)?
    var configsSpec: (() -> XConfigsSpec.Type)?

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    private init() {}

    func getConfigInfos() -> [ConfigInfo] {
        guard let spec = configsSpec?() else { fatalError("Must set the config spec") }
        let instance = spec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    public func set(configsSpec: @escaping (() -> XConfigsSpec.Type)) {
        self.configsSpec = configsSpec
    }

    public func set(configStore: @escaping (() -> ConfigStoreProtocol)) {
        self.configStore = configStore
    }

    public func set(remoteKVProvider: @escaping (() -> RemoteKeyValueProvider)) {
        self.remoteKVProvider = remoteKVProvider
    }

    public func downloadLatest() {
        _ = remoteKVProvider?().provide()
    }

    func get<Value>(for key: String) -> Value? {
        guard isOverriden else { return configStore?().getRemoteValue(for: key) }
        return configStore?().getDevValue(for: key)
    }

    func set<Value>(value _: Value, for _: String) {
        guard isOverriden else { return }
        //      configStore?().set(value: value, for: key)
    }

    func resetLocalValues() {
        guard isOverriden else { return }
        //        localKVStore?().deleteAll()
    }
}
