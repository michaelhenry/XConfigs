import Foundation
import XConfigs

extension UserDefaults: KeyValueStore {
    public func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawString = string(forKey: key) else { return nil }
        return Value(rawString: rawString)
    }

    public func set<Value: RawStringValueRepresentable>(value: Value, for key: String) {
        set(value.rawString, forKey: key)
    }

    public func remove(key: String) {
        removeObject(forKey: key)
    }
}
