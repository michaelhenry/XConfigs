#if canImport(UIKit)
    import UIKit
#endif
import Combine
import Foundation

internal var defaultConfigUseCase: XConfigUseCase!

public struct XConfigs {
    private init() {}

    public static func configure(
        with spec: XConfigsSpec.Type,
        keyValueProvider: KeyValueProvider,
        logicHandler: XConfigsLogicHandler = OverrideFromRemoteLogicHandler(),
        option: Option = .readonly
    ) {
        defaultConfigUseCase = XConfigUseCase(spec: spec, keyValueProvider: keyValueProvider, logicHandler: logicHandler, keyValueStore: option.kvStore)
    }

    #if canImport(UIKit)
        public static func configsViewController() throws -> UIViewController {
            guard defaultConfigUseCase.keyValueStore != nil else { throw ConfigError.inAppModificationIsNotAllowed }
            return XConfigsViewController(viewModel: .init(useCase: defaultConfigUseCase))
        }

        public static func show(from vc: UIViewController, animated: Bool = true) throws {
            try vc.present(configsViewController().wrapInsideNavVC(), animated: animated, completion: nil)
        }
    #endif
    public static func setInAppModification(enable: Bool) throws {
        guard defaultConfigUseCase.keyValueStore != nil else { throw ConfigError.inAppModificationIsNotAllowed }
        defaultConfigUseCase.isInAppModificationEnabled = enable
    }
}

public extension XConfigs {
    enum Option {
        case allowInAppModification(InAppModificationOption)
        case readonly

        var kvStore: KeyValueStore? {
            switch self {
            case let .allowInAppModification(option):
                return option.store
            default:
                return nil
            }
        }
    }

    enum ConfigError: Error {
        case inAppModificationIsNotAllowed
    }
}
