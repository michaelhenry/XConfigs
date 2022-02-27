import Foundation
import SwiftSyntax

protocol FeatureFlagValueRepresentable {}

protocol FeatureFlagStore {
    func get<Value: FeatureFlagValueRepresentable>(key: String) -> Value?
    func set<Value: FeatureFlagValueRepresentable>(object: Value, for key: String)
}

extension UserDefaults: FeatureFlagStore {
    func get<Value>(key: String) -> Value? where Value: FeatureFlagValueRepresentable {
        object(forKey: key) as? Value
    }

    func set<Value>(object: Value, for key: String) where Value: FeatureFlagValueRepresentable {
        set(object, forKey: key)
    }
}

class FeatureFlagManager {
    static let manager = FeatureFlagManager()
    var store: FeatureFlagStore = UserDefaults.standard
}

@propertyWrapper
struct FeatureFlag<Value: FeatureFlagValueRepresentable> {
    var key: String
    var defaultValue: Value
    var wrappedValue: Value {
        get { FeatureFlagManager.manager.store.get(key: key) ?? defaultValue }
        set { FeatureFlagManager.manager.store.set(object: newValue, for: key) }
    }

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

extension Bool: FeatureFlagValueRepresentable {}

enum FeatureFlags {
    @FeatureFlag(key: "isOnboardingEnabled", defaultValue: false)
    static var isOnboardingEnabled: Bool
}
