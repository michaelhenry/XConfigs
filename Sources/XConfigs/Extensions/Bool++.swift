import Foundation

extension Bool: RawStringRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = Bool(rawString) ?? false
    }
}
