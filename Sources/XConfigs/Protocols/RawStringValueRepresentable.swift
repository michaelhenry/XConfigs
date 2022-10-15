import Foundation

public protocol RawStringValueRepresentable {
    var rawString: String { get }

    init?(rawString: String)
}
