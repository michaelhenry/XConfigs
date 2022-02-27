import XCTest
@testable import FeatureFlag

final class FeatureFlagTests: XCTestCase {
    let mockUserDefault = UserDefaults.standard

    func testDefault() throws {
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertFalse(FeatureFlags.isOnboardingEnabled)
    }

    func testHappyDefault() throws {
        mockUserDefault.set(object: true, for: "isOnboardingEnabled")
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertTrue(FeatureFlags.isOnboardingEnabled)
    }

    func testSetAndGetValue() throws {
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertFalse(FeatureFlags.isOnboardingEnabled)
        FeatureFlags.isOnboardingEnabled = true
        XCTAssertTrue(FeatureFlags.isOnboardingEnabled)
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
