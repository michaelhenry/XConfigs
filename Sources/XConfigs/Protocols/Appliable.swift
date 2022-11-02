import Foundation

protocol Appliable {}

extension Appliable {
    func apply(block: (inout Self) -> Void) -> Self {
        var instance = self
        block(&instance)
        return instance
    }
}
