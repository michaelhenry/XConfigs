import Combine
import Foundation
import UIKit

internal var defaultConfigUseCase: XConfigUseCase!

public struct XConfigs {
    private init() {}

    public static func configure(
        with spec: XConfigsSpec.Type,
        keyValueProvider: KeyValueProvider,
        logicHandler: XConfigsLogicHandler = OverrideFromRemoteLogicHandler(),
        keyValueStore: KeyValueStore? = nil
    ) {
        defaultConfigUseCase = XConfigUseCase(spec: spec, keyValueProvider: keyValueProvider, logicHandler: logicHandler, keyValueStore: keyValueStore)
    }

    public static func configsViewController() -> UIViewController {
        XConfigsViewController(viewModel: .init(useCase: defaultConfigUseCase))
    }

    public static function show(from vc: UIViewController) {
        vc.present(configsViewController(), animated: true, completion: nil)
    }
}
