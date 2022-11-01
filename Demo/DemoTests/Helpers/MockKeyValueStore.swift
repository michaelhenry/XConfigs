import Foundation
import XConfigs

final class MockKeyValueStore: KeyValueStore {
    var keyValues: [String: String] = [:]

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawString = keyValues[key] else { return nil }
        return Value(rawString: rawString)
    }

    func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        keyValues[key] = value.rawString
    }

    func remove(key: String) {
        keyValues.removeValue(forKey: key)
    }
}
