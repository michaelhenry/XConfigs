import Foundation
import SQLite

public protocol KeyValueStore {
    func get<Value: RawStringValueRepresentable>(for key: String) -> Value?
    func set<Value: RawStringValueRepresentable>(value: Value, for key: String)
    func remove(key: String)
}
