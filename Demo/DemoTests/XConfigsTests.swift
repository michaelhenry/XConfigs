import Combine
import XCTest
@testable import Demo
@testable import XConfigs

final class XConfigsTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        subscriptions = Set<AnyCancellable>()
        XConfigs.configure(with: MockFeatureFlags.self, kvStore: MockKeyValueStore(), remoteKeyValueProvider: MockKeyValueProvider())
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testhOverrideDisabled() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = false

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
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

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

    func testhOverridingUpdateValues() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

        let reloadPublisher = PassthroughSubject<Void, Never>()
        let updateValuePublisher = PassthroughSubject<KeyValue, Never>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: updateValuePublisher.eraseToAnyPublisher(),
            overrideConfigPublisher: Empty().eraseToAnyPublisher(),
            resetPublisher: Empty().eraseToAnyPublisher()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        XCTAssertEqual(MockFeatureFlags.shared.maxRetry, 10)
        XCTAssertEqual(MockFeatureFlags.shared.maxRate, 1.0)

        reloadPublisher.send(())
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))

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

        XCTAssertEqual(sectionItemsModels[1], [
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
                .textInput(.init(key: "maxRetry", value: "20")),
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

        XCTAssertEqual(sectionItemsModels[2], [
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
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "maxRate", value: "0.99")),
            ]),
        ])

        XCTAssertEqual(MockFeatureFlags.shared.maxRetry, 20)
        XCTAssertEqual(MockFeatureFlags.shared.maxRate, 0.99)
    }

    func testTryToOverrideValueButNotOverridable() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = false

        let reloadPublisher = PassthroughSubject<Void, Never>()
        let updateValuePublisher = PassthroughSubject<KeyValue, Never>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: updateValuePublisher.eraseToAnyPublisher(),
            overrideConfigPublisher: Empty().eraseToAnyPublisher(),
            resetPublisher: Empty().eraseToAnyPublisher()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        XCTAssertEqual(MockFeatureFlags.shared.maxRetry, 10)
        XCTAssertEqual(MockFeatureFlags.shared.maxRate, 1.0)

        reloadPublisher.send(())
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .overrideConfig(false),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .overrideConfig(false),
            ]),
        ])
        XCTAssertEqual(MockFeatureFlags.shared.maxRetry, 10)
        XCTAssertEqual(MockFeatureFlags.shared.maxRate, 1.0)
    }

    func testhOverridingUpdateValuesThenReset() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

        let reloadPublisher = PassthroughSubject<Void, Never>()
        let updateValuePublisher = PassthroughSubject<KeyValue, Never>()
        let resetPublisher = PassthroughSubject<Void, Never>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: updateValuePublisher.eraseToAnyPublisher(),
            overrideConfigPublisher: Empty().eraseToAnyPublisher(),
            resetPublisher: resetPublisher.eraseToAnyPublisher()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        XCTAssertEqual(MockFeatureFlags.shared.maxRetry, 10)
        XCTAssertEqual(MockFeatureFlags.shared.maxRate, 1.0)

        reloadPublisher.send(())
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))
        resetPublisher.send(())

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

        XCTAssertEqual(sectionItemsModels[1], [
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
                .textInput(.init(key: "maxRetry", value: "20")),
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

        XCTAssertEqual(sectionItemsModels[2], [
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
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "maxRate", value: "0.99")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[3], [
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
        XCTAssertEqual(sectionItemsModels.count, 4)
    }
}
