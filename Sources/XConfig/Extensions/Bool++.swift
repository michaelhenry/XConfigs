import Foundation

extension Bool: RawStringRepresentable {
    var rawString: String {
        "\(self)"
    }

    init(rawString: String) {
        self = Bool(rawString) ?? false
    }
}
