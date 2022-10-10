import Foundation

@propertyWrapper
struct XConfig<Value: RawStringRepresentable>: ConfigInfo {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        XConfigUseCase.shared.get(for: key) ?? defaultValue
    }

    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var configKey: String {
        key
    }

    var configValue: RawStringRepresentable {
        wrappedValue
    }

    var configDefaultValue: RawStringRepresentable {
        defaultValue
    }
}
