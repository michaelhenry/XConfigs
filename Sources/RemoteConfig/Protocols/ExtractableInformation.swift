import Foundation

protocol ExtractableInformation {
    var extractedKey: String { get }
    var extractedValue: Any { get }
    var extractedDefaultValue: Any { get }
}
