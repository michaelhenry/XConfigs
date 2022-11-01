import Foundation
import XConfigs

final class MockKeyValueProvider: KeyValueProvider {
    private var next: [String: Any] = [:]

    func mock(next: [String: Any]) {
        self.next = next
    }

    func get<Value>(for key: String) -> Value? {
        next[key] as? Value
    }
}
