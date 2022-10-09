import Combine
import Foundation

protocol RemoteConfigUseCaseProtocol {
    // Can provide key-value from remote
    func provide() -> AnyPublisher<[String: Any], Error>

    // Can override remote values from the local on development build (isDebug == true)

    // can get value from key
    // returns local value if override option is enable otherwise return the remote value

    // can set local value if override option is enable otherwise skip this

    // can reset local values
}
