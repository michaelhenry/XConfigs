import Foundation

@propertyWrapper
public struct XConfig<Value: RawStringValueRepresentable>: ConfigInfo {
    public let key: String
    public let displayName: String?
    public let defaultValue: Value
    public let group: XConfigGroup

    public var wrappedValue: Value {
        defaultConfigUseCase.get(for: key, defaultValue: defaultValue, group: group).value
    }

    public init(key: String, displayName: String? = nil, defaultValue: Value, group: XConfigGroup = .default) {
        self.key = key
        self.displayName = displayName
        self.defaultValue = defaultValue
        self.group = group
    }

    public var configKey: String {
        key
    }

    public var configValue: RawStringValueRepresentable {
        wrappedValue
    }

    public var readonly: Bool {
        defaultConfigUseCase.get(for: key, defaultValue: defaultValue, group: group).readonly
    }
}

public struct XConfigGroup: Hashable {
    public let name: String
    public let sort: Int

    public init(name: String, sort: Int) {
        self.name = name
        self.sort = sort
    }

    public static let `default` = Self(name: "", sort: 0)
}
