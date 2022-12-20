import Combine
import Foundation
import UIKit

internal var defaultConfigUseCase: XConfigUseCase!

public struct XConfigs {
    private init() {}

    public static func configure(
        with spec: XConfigsSpec.Type,
        keyValueProvider: KeyValueProvider,
        keyValueStore: KeyValueStore = EmptyKeyValueStore(),
        logicHandler: XConfigsLogicHandler = OverrideFromRemoteLogicHandler()
    ) {
        defaultConfigUseCase = XConfigUseCase(spec: spec, keyValueProvider: keyValueProvider, keyValueStore: keyValueStore, logicHandler: logicHandler)
    }

    public static func configsViewController() -> UIViewController {
        XConfigsViewController(viewModel: .init(useCase: defaultConfigUseCase))
    }
}
