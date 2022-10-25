import Foundation

extension URL: RawStringValueRepresentable {
    public var rawString: String {
        absoluteString
    }

    public init?(rawString: String) {
        guard let url = URL(string: rawString) else { return nil }
        self = url
    }
}
