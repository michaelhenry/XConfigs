import Foundation

extension String: RawStringValueRepresentable {
    public var rawString: String {
        self
    }

    public init(rawString: String) {
        self = rawString
    }
}
