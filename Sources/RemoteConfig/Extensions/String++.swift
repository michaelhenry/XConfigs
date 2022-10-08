import Foundation

extension String: RawStringRepresentable {
    var rawString: String {
        self
    }

    init(rawString: String) {
        self = rawString
    }
}
