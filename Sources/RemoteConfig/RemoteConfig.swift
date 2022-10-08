import Foundation

@propertyWrapper
struct RemoteConfig<Value: RawStringRepresentable>: ExtractableConfigInformation {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        RemoteConfigManager.manager.valueProvider.get(key: key) ?? defaultValue
    }

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var extractedKey: String {
        key
    }

    var extractedValue: RawStringRepresentable {
        wrappedValue
    }

    var extractedDefaultValue: RawStringRepresentable {
        defaultValue
    }
}
