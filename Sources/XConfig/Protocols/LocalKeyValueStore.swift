import Foundation
import SQLite

struct Config {
    let key: String
    let remoteValue: String?
    let devValue: String?
}

protocol ConfigStoreProtocol {
    func getRemoteValue<Value>(for key: String) -> Value?
    func getDevValue<Value>(for key: String) -> Value?
    func deleteAll()
}
