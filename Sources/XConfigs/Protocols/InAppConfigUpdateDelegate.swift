import Foundation

public protocol InAppConfigUpdateDelegate {
    func configWillUpdate(key: String, value: RawStringValueRepresentable, store: KeyValueStore)
}
