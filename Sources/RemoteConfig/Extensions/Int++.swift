import Foundation

extension Int: RawStringRepresentable {
    var rawString: String {
        "\(self)"
    }

    init(rawString: String) {
        self = Int(rawString) ?? 0
    }
}
