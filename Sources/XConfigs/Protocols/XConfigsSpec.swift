import Foundation

public protocol XConfigsSpec {
    static var shared: Self { get }

    init()
}
