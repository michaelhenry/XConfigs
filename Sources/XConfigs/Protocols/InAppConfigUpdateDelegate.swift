import Foundation

/// A delegate that listen to the key-value changed done inside the in-app config screen.
public protocol InAppConfigUpdateDelegate {
    func configWillUpdate(key: String, value: RawStringValueRepresentable, store: KeyValueStore)
}
