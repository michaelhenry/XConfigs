import Foundation
import SQLite

public protocol KeyValueStore {
    func get<Value: RawStringRepresentable>(for key: String) -> Value?
    func set<Value: RawStringRepresentable>(value: Value, for key: String)
}
