import Foundation

/// A protocol for parsing a configuration spec file (`XConfigsSpec`).
public protocol ConfigInfo {
    var configKey: String { get }
    var displayName: String? { get }
    var configValue: RawStringValueRepresentable { get }

    var group: XConfigGroup { get }
    var readonly: Bool { get }
}
