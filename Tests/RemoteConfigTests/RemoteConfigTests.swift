import XCTest
@testable import RemoteConfig

final class FeatureFlagTests: XCTestCase {
    let mockUserDefault = UserDefaults.standard

    func testDefault() throws {
        RemoteConfigManager.manager.valueProvider = mockUserDefault
        XCTAssertFalse(MockFeatureFlags.default.isOnboardingEnabled)
    }

    func testRegistration() throws {
        let vm = RemoteConfigViewModel(spec: MockFeatureFlags.self)
        XCTAssertEqual(vm.sectionItemsModels, [
            .init(section: .main, items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiHost", value: "https://google.com")),
                .optionSelection(.init(key: "region", value: "north", choices: ["north", "south", "east", "west"])),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
        ])
    }

    func testHappyDefault() throws {
        mockUserDefault.set(true, forKey: "isOnboardingEnabled")
        RemoteConfigManager.manager.valueProvider = mockUserDefault
        XCTAssertTrue(MockFeatureFlags.default.isOnboardingEnabled)
    }

    func testSetAndGetValue() throws {
        RemoteConfigManager.manager.valueProvider = mockUserDefault
        XCTAssertFalse(MockFeatureFlags.default.isOnboardingEnabled)
        mockUserDefault.set(true, forKey: "isOnboardingEnabled")
        XCTAssertTrue(MockFeatureFlags.default.isOnboardingEnabled)
        XCTAssertTrue(mockUserDefault.bool(forKey: "isOnboardingEnabled"))
    }

    override func tearDown() {
        super.tearDown()
        // Clear store
        mockUserDefault.dictionaryRepresentation().forEach {
            mockUserDefault.removeObject(forKey: $0.key)
        }
    }
}

struct MockFeatureFlags: RemoteConfigSpec {
    static let `default` = Self()

    @RemoteConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @RemoteConfig(key: "apiHost", defaultValue: "https://google.com")
    var apiHost: String

    @RemoteConfig(key: "region", defaultValue: .north)
    var region: Region

    @RemoteConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @RemoteConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @RemoteConfig(key: "rate", defaultValue: 2.5)
    var rate: Double
}

enum Region: String, CaseIterable, RawStringRepresentable {
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
