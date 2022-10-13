import Foundation

public protocol RawStringRepresentable {
    var rawString: String { get }

    init?(rawString: String)
}
