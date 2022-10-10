import Foundation

extension Double: RawStringRepresentable {
    var rawString: String {
        "\(self)"
    }

    init(rawString: String) {
        self = Double(rawString) ?? 0.0
    }
}
