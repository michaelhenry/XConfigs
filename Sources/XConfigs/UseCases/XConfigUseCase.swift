import Combine
import Foundation

public class XConfigUseCase {
    public static let shared = XConfigUseCase()

    private let isOverridenKey = "XConfigs.Debug.isOverriden"

    var isOverriden: Bool {
        get {
            kvStore?().get(for: isOverridenKey) ?? false
        }

        set {
            kvStore?().set(value: newValue, for: isOverridenKey)
        }
    }

    private var kvStore: (() -> KeyValueStore)?
    private var remoteKVProvider: (() -> RemoteKeyValueProvider)?
    private var configsSpec: (() -> XConfigsSpec.Type)?
    private var remoteKeyValues: [String: Any] = [:]

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    private init() {}

    func getConfigs() -> [ConfigInfo] {
        guard isOverriden else { return [] }
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

    public func downloadRemoteConfigs() async throws {
        remoteKeyValues = try await remoteKVProvider?().provide() ?? [:]
        print("remoteKeyValues", remoteKeyValues)
    }

    public func downloadRemoteConfigs(completion: @escaping ((Result<Void, Error>) -> Void)) {
        Task {
            do {
                try await downloadRemoteConfigs()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard isOverriden else { return remoteKeyValues[key] as? Value }
        return kvStore?().get(for: key)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        guard isOverriden else { return }
        kvStore?().set(value: value, for: key)
    }

    func reset() {
        guard isOverriden else { return }
        getConfigs().forEach {
            kvStore?().remove(key: $0.configKey)
        }
    }
}
