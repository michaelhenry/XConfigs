import XCTest
@testable import FeatureFlag

final class FeatureFlagTests: XCTestCase {
  let mockUserDefault = UserDefaults.standard
  
  func testDefault() throws {
    FeatureFlagManager.manager.store = mockUserDefault
    XCTAssertEqual(FeatureFlags.isOnboardingEnabled, false)
  }
  
  func testHappyDefault() throws {
    mockUserDefault.set(object: true, for: "isOnboardingEnabled")
    FeatureFlagManager.manager.store = mockUserDefault
    XCTAssertEqual(FeatureFlags.isOnboardingEnabled, true)
  }
  
  func testSetValue() throws {
    FeatureFlagManager.manager.store = mockUserDefault
    FeatureFlags.isOnboardingEnabled = true
    XCTAssertEqual(FeatureFlags.isOnboardingEnabled, true)
    XCTAssertTrue(mockUserDefault.bool(forKey: "isOnboardingEnabled"))
  }
  
  override func tearDown() {
    super.tearDown()
    mockUserDefault.dictionaryRepresentation().forEach {
      mockUserDefault.removeObject(forKey: $0.key)
    }
  }
}
