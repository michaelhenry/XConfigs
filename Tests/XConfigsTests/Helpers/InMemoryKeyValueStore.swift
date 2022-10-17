import Foundation
@testable import XConfigs

class InMemoryKVStore: KeyValueStore {
    static let shared = InMemoryKVStore()

    private var kv: [String: RawStringValueRepresentable] = [:]

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawString = kv[key]?.rawString else { return nil }
        return Value(rawString: rawString)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        kv[key] = value
    }

    func remove(key: String) {
        kv.removeValue(forKey: key)
    }
}
