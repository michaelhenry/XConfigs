import Foundation
import SQLite

public protocol KeyValueStore {
    func get<Value>(for key: String) -> Value?
    func set<Value>(value: Value, for key: String)
}
