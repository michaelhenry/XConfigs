import Combine
import Foundation
import SnapshotTesting
import XCTest
@testable import XConfigs

final class SnapshotTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        SnapshotTesting.diffTool = "ksdiff"
        subscriptions = Set<AnyCancellable>()
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: MockKeyValueProvider(), keyValueStore: MockKeyValueStore())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Snapshots ViewControllers

    func testhOverrideDisabled() throws {
        let vc = XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(precision: 0.95))
    }

    // BUG: https://github.com/pointfreeco/swift-snapshot-testing/discussions/502
    func testhOverrideEnabled() throws {
        defaultConfigUseCase.isOverriden = true
        let vc = XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(precision: 0.95))
    }

    func testInputValueViewController() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "Hello", value: "World"))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image)
    }

    func testOptionViewController() throws {
        let vc = OptionViewController(viewModel: .init(model: .init(key: "Name", value: "Value1", choices: ["Value1", "Value2", "Value3", "Value4"]))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image(precision: 0.95))
    }

    // MARK: - Snapshots - Views

    func testActionView() throws {
        let view = ActionView().apply {
            $0.configure(with: "Action name")
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image(precision: 0.95))
    }

    func testKeyValueView() throws {
        let view = KeyValueView().apply {
            $0.configure(with: ("Name", "Value"))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image(precision: 0.95))
    }

    func testKeyValueViewWithLongValue() throws {
        let view = KeyValueView().apply {
            $0.configure(with: ("Name", "This a long value. Lorem ipsum sit dolor amet."))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image(precision: 0.95))
    }

    func testToggleView() throws {
        let view = ToggleView().apply {
            $0.configure(with: ("Name", false))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image(precision: 0.95))
    }

    func testToggleViewWithOnValue() throws {
        let view = ToggleView().apply {
            $0.configure(with: ("Name", true))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image(precision: 0.95))
    }
}
