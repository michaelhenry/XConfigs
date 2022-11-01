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
        assertSnapshot(matching: vc.wrapInsideNavVC(), as: .image(on: .iPhoneX, precision: 0.99))
    }

    func testActionView() throws {
        let view = ActionView().apply {
            $0.configure(with: "Action name")
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image)
    }

    func testKeyValueView() throws {
        let view = KeyValueView().apply {
            $0.configure(with: ("Key", "Value"))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image)
    }

    func testToggleView() throws {
        let view = ToggleView().apply {
            $0.configure(with: ("Key", false))
            $0.widthAnchor.constraint(equalToConstant: 320).isActive = true
        }
        assertSnapshot(matching: view, as: .image)
    }

    func testInputValueViewController() throws {
        let vc = InputValueViewController(viewModel: .init(model: .init(key: "Hello", value: "World")))
        assertSnapshot(matching: vc, as: .image(drawHierarchyInKeyWindow: true, perceptualPrecision: 1))
    }

    func testOptionViewController() throws {
        let vc = OptionViewController(viewModel: .init(model: .init(key: "Key", value: "Value1", choices: ["Value1", "Value2", "Value3", "Value4"])))
        assertSnapshot(matching: vc, as: .image(on: .iPhoneX))
    }
}
