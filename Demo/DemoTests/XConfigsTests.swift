import RxCocoa
import RxSwift
import XCTest
@testable import Demo
@testable import XConfigs

final class XConfigsTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    private var disposeBag = DisposeBag()
    private var provider: MockKeyValueProvider!
    private var store: MockKeyValueStore!

    private let regionChoices = ["north", "south", "east", "west"].map { Choice(displayName: $0, value: $0) }

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        provider = MockKeyValueProvider()
        store = MockKeyValueStore()
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: provider, keyValueStore: store)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testhOverrideDisabled() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = false

        let reloadPublisher = PublishSubject<Void>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: .empty(),
            overrideConfigPublisher: .empty(),
            resetPublisher: .empty()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.drive(onNext: { secItem in
            sectionItemsModels.append(secItem)
        })
        .disposed(by: disposeBag)

        reloadPublisher.onNext(())

        XCTAssertEqual(sectionItemsModels[0], .init(
            arrayLiteral: .init(section: .main, items: [
                .overrideConfig(false),
            ])))
    }

    func testhOverrideEnabled() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

        let reloadPublisher = PublishSubject<Void>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: .empty(),
            overrideConfigPublisher: .empty(),
            resetPublisher: .empty()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.drive(onNext: { secItem in
            sectionItemsModels.append(secItem)
        })
        .disposed(by: disposeBag)

        reloadPublisher.onNext(())

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])
    }

    func testhOverridingUpdateValues() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

        let reloadPublisher = PublishSubject<Void>()
        let updateValuePublisher = PublishSubject<KeyValue>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: updateValuePublisher,
            overrideConfigPublisher: .empty(),
            resetPublisher: .empty()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.drive(onNext: { secItem in
            sectionItemsModels.append(secItem)
        })
        .disposed(by: disposeBag)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        reloadPublisher.onNext(())
        updateValuePublisher.onNext(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.onNext(.init(key: "maxRate", value: "0.99"))

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[2], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "0.99")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(MockConfigs.shared.maxRetry, 20)
        XCTAssertEqual(MockConfigs.shared.maxRate, 0.99)
    }

    func testTryToOverrideValueButNotOverridable() throws {
        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = false

        let reloadPublisher = PublishSubject<Void>()
        let updateValuePublisher = PublishSubject<KeyValue>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: updateValuePublisher,
            overrideConfigPublisher: .empty(),
            resetPublisher: .empty()
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.drive(onNext: { secItem in
            sectionItemsModels.append(secItem)
        })
        .disposed(by: disposeBag)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        reloadPublisher.onNext(())
        updateValuePublisher.onNext(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.onNext(.init(key: "maxRate", value: "0.99"))

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
        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)
    }

    func testhOverridingUpdateValuesThenReset() throws {
        // use this value instead of the assigned defaultValue
        provider.mock(next: [
            "isOnboardingEnabled": true,
            "apiURL": "https://prod.google.com",
        ])

        let viewModel = XConfigsViewModel()
        defaultConfigUseCase.isOverriden = true

        let reloadPublisher = PublishSubject<Void>()
        let updateValuePublisher = PublishSubject<KeyValue>()
        let resetPublisher = PublishSubject<Void>()
        let output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: updateValuePublisher,
            overrideConfigPublisher: .empty(),
            resetPublisher: resetPublisher
        ))

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.drive(onNext: { secItem in
            sectionItemsModels.append(secItem)
        })
        .disposed(by: disposeBag)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        reloadPublisher.onNext(())
        updateValuePublisher.onNext(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.onNext(.init(key: "maxRate", value: "0.99"))
        resetPublisher.onNext(())

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: true)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: true)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[2], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: true)),
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "20")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "0.99")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])

        XCTAssertEqual(sectionItemsModels[3], [
            .init(section: .main, items: [
                .overrideConfig(true),
                .action("Reset"),
            ]),
            .init(section: .group(""), items: [
                .toggle(.init(key: "isOnboardingEnabled", value: true)), // uses remote
                .textInput(.init(key: "apiURL", value: "https://prod.google.com")), // uses remote
                .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
            .init(section: .group("Feature 1"), items: [
                .textInput(.init(key: "maxScore", value: "100")),
                .textInput(.init(key: "maxRate", value: "1.0")),
            ]),
            .init(section: .group("Feature 2"), items: [
                .textInput(.init(key: "height", value: "44.0")),
                .textInput(.init(key: "width", value: "320.0")),
            ]),
        ])
        XCTAssertEqual(sectionItemsModels.count, 4)
    }
}
