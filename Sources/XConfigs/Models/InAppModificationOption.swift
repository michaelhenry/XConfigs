import Foundation

public struct InAppModificationOption {
  public let store: KeyValueStore

  public init(store: KeyValueStore) {
    self.store = store
  }
}
