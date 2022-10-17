import Foundation

public protocol ConfigInfo {
    var configKey: String { get }
    var configValue: RawStringValueRepresentable { get }
    var configDefaultValue: RawStringValueRepresentable { get }

    var group: XConfigGroup { get }
}
