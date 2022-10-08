import Foundation

protocol ExtractableConfigInformation {
    var extractedKey: String { get }
    var extractedValue: RawStringRepresentable { get }
    var extractedDefaultValue: RawStringRepresentable { get }
}
