import Foundation

public struct InAppModificationOption {
    public let store: KeyValueStore
    public let updateDelegate: InAppConfigUpdateDelegate?

    public init(store: KeyValueStore, updateDelegate: InAppConfigUpdateDelegate? = nil) {
        self.store = store
        self.updateDelegate = updateDelegate
    }
}
