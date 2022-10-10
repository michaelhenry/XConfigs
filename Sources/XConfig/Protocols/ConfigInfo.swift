import Foundation

protocol ConfigInfo {
    var configKey: String { get }
    var configValue: RawStringRepresentable { get }
    var configDefaultValue: RawStringRepresentable { get }
}
