import Combine
import Foundation

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type, kvStore: KeyValueStore = UserDefaults.standard, remoteKeyValueProvider: RemoteKeyValueProvider? = nil) {
        let useCase = XConfigUseCase.shared
        useCase.set(configsSpec: { spec })
        useCase.set(kvStore: { kvStore })
        if let remoteKeyValueProvider {
            useCase.set(remoteKVProvider: { remoteKeyValueProvider })
        }
    }
}
