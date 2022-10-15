import Foundation

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type) {
        XConfigUseCase.shared.set(configsSpec: { spec })
        XConfigUseCase.shared.set(kvStore: { InMemoryKVStore.shared })
    }
}
