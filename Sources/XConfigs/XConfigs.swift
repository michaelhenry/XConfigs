import Foundation

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type, kvStore: KeyValueStore = UserDefaults.standard) {
        XConfigUseCase.shared.set(configsSpec: { spec })
        XConfigUseCase.shared.set(kvStore: { kvStore })
    }
}
