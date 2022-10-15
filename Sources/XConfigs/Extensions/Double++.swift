import Foundation

extension Double: RawStringValueRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = Double(rawString) ?? 0.0
    }
}
