import XCTest
@testable import XConfigs

final class XConfigTests: XCTestCase {
    func testRegistration() throws {}
}

struct MockConfigs: XConfigsSpec {
    static let `default` = Self()

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiHost", defaultValue: "https://google.com")
    var apiHost: String

    @XConfig(key: "region", defaultValue: .north)
    var region: Region

    @XConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @XConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @XConfig(key: "rate", defaultValue: 2.5)
    var rate: Double
}

enum Region: String, CaseIterable, RawStringValueRepresentable {
    case north
    case south
    case east
    case west

    init(rawString: String) {
        self = .init(rawValue: rawString) ?? .north
    }

    var rawString: String {
        rawValue
    }
}

class MockRemoteKVProvider: RemoteKeyValueProvider {
    func provide() -> [String: Any] {
        [:]
    }

    func get<Value>(for _: String) -> Value? {
        nil
    }
}
