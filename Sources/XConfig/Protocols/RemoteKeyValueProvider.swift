import Foundation

protocol RemoteKeyValueProvider {
//    func provide() async -> [String: Any]
    func get<Value>(for key: String) -> Value?
}
