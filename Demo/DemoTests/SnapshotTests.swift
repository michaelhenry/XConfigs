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
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: MockKeyValueProvider(), option: .allowInAppModification(.init(store: MockKeyValueStore())))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Snapshots ViewControllers

    func testInAppModificationDisabled() throws {
        let vc = try XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(precision: 0.95))
    }

    func testInAppModificationEnabledButWithReadonlyOption() throws {
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: MockKeyValueProvider(), option: .readonly)
        XCTAssertThrowsError(try XConfigs.setInAppModification(enable: true))
        XCTAssertThrowsError(try XConfigs.configsViewController())
    }

    // BUG: https://github.com/pointfreeco/swift-snapshot-testing/discussions/502
    func testInAppModificationEnabled() throws {
        try XConfigs.setInAppModification(enable: true)
        let vc = try XConfigs.configsViewController()
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(precision: 0.95))
    }

    func testInputValueViewController() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "Hello", value: "World", displayName: "Hello"))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image)
    }

    func testInputValueViewControllerJSON() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "JSON", value: "{\"name\":\"Kel\", \"city\": \"Melbourne\"        }", displayName: "Contact"))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image)
    }

    func testInputValueViewControllerURL() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "URL", value: "https://google.com", displayName: "URL"))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image)
    }

    func testOptionViewController() throws {
        let choices = [1, 2, 3, 4].map { "Value\($0)" }.map { Choice(displayName: $0, value: $0) }
        let vc = OptionViewController(viewModel: .init(model: .init(key: "Name", value: "Value1", choices: choices, displayName: "Name"))).wrapInsideNavVC()
        assertSnapshot(matching: vc, as: .image(precision: 0.95))
    }

    func testShowShortcutFunction() throws {
        try XConfigs.setInAppModification(enable: true)
        let hostVC = UIViewController()
        try XConfigs.show(from: hostVC, animated: false)
        assertSnapshot(matching: hostVC, as: Snapshotting.windowsImageWithAction {
            try? XConfigs.show(from: hostVC)
        })
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
