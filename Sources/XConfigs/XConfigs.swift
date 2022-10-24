import Combine
import Foundation
import UIKit

internal var defaultConfigUseCase: XConfigUseCase!

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type, kvStore: KeyValueStore = UserDefaults.standard, remoteKeyValueProvider: KeyValueProvider) {
        defaultConfigUseCase = XConfigUseCase(spec: spec, kvStore: kvStore, remoteKVProvider: remoteKeyValueProvider)
    }

    public static func configsViewController() -> UIViewController {
        XConfigsViewController(viewModel: .init(useCase: defaultConfigUseCase))
    }
}
