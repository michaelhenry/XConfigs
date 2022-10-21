import Combine
import Foundation
import SnapshotTesting
import XCTest
@testable import XConfigs

final class SnapshotTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        subscriptions = Set<AnyCancellable>()
        XConfigs.configure(with: MockFeatureFlags.self, kvStore: InMemoryKVStore(), remoteKeyValueProvider: MockRemoteKVProvider())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDisabledOverriding() throws {
        let vc = XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(on: .iPhoneX))
    }

    func testhOverrideEnabled() throws {
        defaultConfigUseCase.isOverriden = true
        let vc = XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(on: .iPhoneX))
    }
}
