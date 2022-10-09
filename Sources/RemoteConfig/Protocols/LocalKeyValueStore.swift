import Foundation

protocol LocalKeyValueStore {
    func get<Value>(key: String) -> Value?
    func set<Value>(value: Value, for key: String)
}
