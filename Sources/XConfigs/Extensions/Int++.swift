import Foundation

extension Int: RawStringRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = Int(rawString) ?? 0
    }
}
