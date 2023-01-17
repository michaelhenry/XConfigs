import Foundation

public protocol ConfigInfo {
    var configKey: String { get }
    var displayName: String? { get }
    var configValue: RawStringValueRepresentable { get }

    var group: XConfigGroup { get }
}
