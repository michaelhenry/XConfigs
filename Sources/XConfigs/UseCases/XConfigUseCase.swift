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
    private var remoteKeyValues: [String: Any] = [:]

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

    func downloadRemoteConfigs() async throws {
        remoteKeyValues = try await remoteKVProvider.provide()
        print("remoteKeyValues", remoteKeyValues)
    }

//    public func downloadRemoteConfigs(completion: @escaping ((Result<Void, Error>) -> Void)) {
//        Task {
//            do {
//                try await downloadRemoteConfigs()
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard isOverriden else { return remoteKeyValues[key] as? Value }
        return developmentKvStore.get(for: key)
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
