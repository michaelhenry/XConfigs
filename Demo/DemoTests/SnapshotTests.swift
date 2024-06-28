import Foundation
import SnapshotTesting
import XCTest
@testable import XConfigs

final class SnapshotTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel

    override func setUpWithError() throws {
        try super.setUpWithError()
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: MockKeyValueProvider(), option: .allowInAppModification(.init(store: MockKeyValueStore())))
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    // MARK: - Snapshots ViewControllers

    func testInAppModificationDisabled() throws {
        assertVCSnapshotWithActionFromHost {
            try? XConfigs.show(from: $0, animated: false)
        }
    }

    func testInAppModificationEnabledButWithReadonlyOption() throws {
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: MockKeyValueProvider(), option: .readonly)
        XCTAssertThrowsError(try XConfigs.setInAppModification(enable: true))
        XCTAssertThrowsError(try XConfigs.configsViewController())
    }

    func testInAppModificationEnabled() throws {
        try XConfigs.setInAppModification(enable: true)
        assertVCSnapshotWithActionFromHost {
            try? XConfigs.show(from: $0, animated: false)
        }
    }

    func testInputValueViewController() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "Hello", value: "World", displayName: "Hello"))).wrapInsideNavVC().preferAsHalfSheet()
        assertVCSnapshotWithActionFromHost {
            $0.present(vc, animated: false)
        }
    }

    func testInputValueViewControllerJSON() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "JSON", value: "{\"name\":\"Kel\", \"city\": \"Melbourne\"        }", displayName: "Contact"))).wrapInsideNavVC().preferAsHalfSheet()
        assertVCSnapshotWithActionFromHost {
            $0.present(vc, animated: false)
        }
    }

    func testInputValueViewControllerURL() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "URL", value: "https://google.com", displayName: "URL"))).wrapInsideNavVC().preferAsHalfSheet()
        assertVCSnapshotWithActionFromHost {
            $0.present(vc, animated: false)
        }
    }

    func testOptionViewController() throws {
        let choices = [1, 2, 3, 4].map { "Value\($0)" }.map { Choice(displayName: $0, value: $0) }
        let vc = OptionViewController(viewModel: .init(model: .init(key: "Name", value: "Value1", choices: choices, displayName: "Name"))).wrapInsideNavVC().preferAsHalfSheet()
        assertVCSnapshotWithActionFromHost {
            $0.present(vc, animated: false)
        }
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

    private func assertVCSnapshotWithActionFromHost(
        timeout: TimeInterval = 2,
        _ action: @escaping (UIViewController) -> Void,
        file: StaticString = #file,
        testName: String = #function,
        line: UInt = #line
    ) {
        let hostVC = UIViewController()
        assertSnapshot(matching: hostVC, as: .windowsImageWithAction {
            action(hostVC)
        }, timeout: timeout, file: file, testName: testName, line: line)
    }
}
