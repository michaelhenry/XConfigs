import Combine
import XCTest
@testable import Demo
@testable import XConfigs

final class DemoTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        subscriptions = Set<AnyCancellable>()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testhOverrideDisabled() throws {
        XConfigs.configure(with: MockFeatureFlags.self, kvStore: InMemoryKVStore())
        let useCase = XConfigUseCase.shared
        let viewModel = XConfigsViewModel()
        useCase.isOverriden = false

        let reloadPublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: Empty().eraseToAnyPublisher(),
            overrideConfigPublisher: Empty().eraseToAnyPublisher(),
            resetPublisher: Empty().eraseToAnyPublisher()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send(())

        XCTAssertEqual(sectionItemsModels[0], .init(
            arrayLiteral: .init(section: .main, items: [
                .overrideConfig(false),
            ])))
    }

    func testhOverrideEnabled() throws {
        XConfigs.configure(with: MockFeatureFlags.self, kvStore: InMemoryKVStore())
        let useCase = XConfigUseCase.shared
        let viewModel = XConfigsViewModel()
        useCase.isOverriden = true

        let reloadPublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: Empty().eraseToAnyPublisher(),
            overrideConfigPublisher: Empty().eraseToAnyPublisher(),
            resetPublisher: Empty().eraseToAnyPublisher()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send(())

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiHost", value: "https://google.com")),
                .optionSelection(.init(key: "region", value: "north", choices: [
                    "north", "south", "east", "west",
                ])),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
        ])
    }
}
