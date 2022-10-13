import Foundation

@propertyWrapper
public struct XConfig<Value: RawStringRepresentable>: ConfigInfo {
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

    public var configValue: RawStringRepresentable {
        wrappedValue
    }

    public var configDefaultValue: RawStringRepresentable {
        defaultValue
    }
}
