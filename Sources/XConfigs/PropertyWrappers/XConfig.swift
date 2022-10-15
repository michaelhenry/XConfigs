import Foundation

@propertyWrapper
public struct XConfig<Value: RawStringValueRepresentable>: ConfigInfo {
    let key: String
    let defaultValue: Value

    public var wrappedValue: Value {
        XConfigUseCase.shared.get(for: key) ?? defaultValue
    }

    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var configKey: String {
        key
    }

    public var configValue: RawStringValueRepresentable {
        wrappedValue
    }

    public var configDefaultValue: RawStringValueRepresentable {
        defaultValue
    }
}
