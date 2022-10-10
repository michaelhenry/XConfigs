import Combine
import Foundation

class XConfigUseCase {
    static let shared = XConfigUseCase()

    var isOverriden: Bool = false
    var localKVStore: (() -> LocalKeyValueStore)?
    var remoteKVProvider: (() -> RemoteKeyValueProvider)?

    // To update the local kv store and remote kv provider, please use the assigned method for it.
    private init() {}

    func getConfigInfos(from spec: any XConfigSpec.Type) -> [ConfigInfo] {
        let instance = spec.init()
        let mirror = Mirror(reflecting: instance)
        return mirror.children.compactMap { $0.value as? ConfigInfo }
    }

    func update(localKVStore: @escaping (() -> LocalKeyValueStore)) {
        self.localKVStore = localKVStore
    }

    func update(remoteKVProvider: @escaping (() -> RemoteKeyValueProvider)) {
        self.remoteKVProvider = remoteKVProvider
    }

    //  func provide() -> AnyPublisher<[String : Any], Error> {
//    return Just([String: Any]())
//      .setFailureType(to: Error.self)
//      .eraseToAnyPublisher()
    //  }

    func get<Value>(for key: String) -> Value? {
        guard isOverriden else { return remoteKVProvider?().get(for: key) }
        return localKVStore?().get(key: key)
    }

    func set<Value>(value: Value, for key: String) {
        guard isOverriden else { return }
        localKVStore?().set(value: value, for: key)
    }

    func resetLocalValues() {
        guard isOverriden else { return }
        localKVStore?().deleteAll()
    }
}
