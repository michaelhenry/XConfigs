import Foundation

extension Bool: RawStringValueRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = Bool(rawString) ?? false
    }
}
