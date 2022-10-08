import Foundation

protocol RawStringRepresentable {
    var rawString: String { get }

    init?(rawString: String)
}
