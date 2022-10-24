import XConfigs
import XCTest

class MockRemoteKVProvider: KeyValueProvider {
    func provide() async throws -> [String: Any] {
        [:]
    }
}

struct MockFeatureFlags: XConfigsSpec {
    static let shared = Self()

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

    @XConfig(key: "maxScore", defaultValue: 100, group: .feature1)
    var maxScore: Int

    @XConfig(key: "maxRate", defaultValue: 1.0, group: .feature2)
    var maxRate: Double
}

extension XConfigGroup {
    static let feature1 = Self(name: "Feature 1", sort: 1)
    static let feature2 = Self(name: "Feature 2", sort: 2)
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
