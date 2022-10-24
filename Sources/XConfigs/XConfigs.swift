import Combine
import Foundation
import UIKit

internal var defaultConfigUseCase: XConfigUseCase!

public struct XConfigs {
    private init() {}

    public static func configure(with spec: XConfigsSpec.Type, remoteKeyValueProvider: KeyValueProvider, developmentKvStore: KeyValueStore = UserDefaults.standard) {
        defaultConfigUseCase = XConfigUseCase(spec: spec, remoteKVProvider: remoteKeyValueProvider, developmentKvStore: developmentKvStore)
    }

    public static func configsViewController() -> UIViewController {
        XConfigsViewController(viewModel: .init(useCase: defaultConfigUseCase))
    }
}
