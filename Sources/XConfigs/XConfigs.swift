import Foundation

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type, kvStore: KeyValueStore = UserDefaults.standard) {
        let useCase = XConfigUseCase.shared
        useCase.set(configsSpec: { spec })
        useCase.set(kvStore: { kvStore })
//        useCase.set(remoteKVProvider: { })
    }
}
