import Foundation

extension String: RawStringRepresentable {
    public var rawString: String {
        self
    }

    public init(rawString: String) {
        self = rawString
    }
}
