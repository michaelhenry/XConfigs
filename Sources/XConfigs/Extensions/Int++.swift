import Foundation

extension Int: RawStringValueRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = Int(rawString) ?? 0
    }
}
