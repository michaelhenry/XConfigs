import RxCocoa
import RxSwift
import RxTest
import XCTest
@testable import Demo
@testable import XConfigs

final class XConfigsTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    typealias SecItemsModel = SectionItemsModel<ViewModel.Section, ViewModel.Item>
    private var disposeBag = DisposeBag()
    private var provider: MockKeyValueProvider!
    private var store: MockKeyValueStore!
    private var scheduler: TestScheduler!

    let reloadPublisher = PublishSubject<Void>()
    let updateValuePublisher = PublishSubject<KeyValue>()
    let overrideConfigPublisher = PublishSubject<Bool>()
    let resetPublisher = PublishSubject<Void>()
    let selectItemPublisher = PublishSubject<ViewModel.Item>()
    let dismissPublisher = PublishSubject<Void>()

    private var output: XConfigsViewModel.Output!

    private let regionChoices = ["north", "south", "east", "west"].map { Choice(displayName: $0, value: $0) }

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        provider = MockKeyValueProvider()
        store = MockKeyValueStore()
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: provider, keyValueStore: store)

        let viewModel = XConfigsViewModel()
        output = viewModel.transform(input: .init(
            reloadPublisher: reloadPublisher,
            updateValuePublisher: updateValuePublisher,
            overrideConfigPublisher: overrideConfigPublisher,
            resetPublisher: resetPublisher,
            selectItemPublisher: selectItemPublisher,
            dismissPublisher: dismissPublisher
        ))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testhOverrideDisabled() throws {
        defaultConfigUseCase.isOverriden = false

        let title = scheduler.createObserver(String.self)
        let sectionItemsModels = scheduler.createObserver([SecItemsModel].self)

        output.title.drive(title).disposed(by: disposeBag)
        output.sectionItemsModels.drive(sectionItemsModels).disposed(by: disposeBag)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, ()),
            ]).bind(to: reloadPublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: OUTPUTS

        XCTAssertEqual(sectionItemsModels.events, [
            .next(0, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: false),
                ]),
            ]),
        ])
    }

    func testhOverrideEnabled() throws {
        defaultConfigUseCase.isOverriden = true

        let title = scheduler.createObserver(String.self)
        let sectionItemsModels = scheduler.createObserver([SecItemsModel].self)

        output.title.drive(title).disposed(by: disposeBag)
        output.sectionItemsModels.drive(sectionItemsModels).disposed(by: disposeBag)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, ()),
            ]).bind(to: reloadPublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: OUTPUTS

        XCTAssertEqual(sectionItemsModels.events, [
            .next(0, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "10")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
        ])
    }

    func testhOverridingUpdateValues() throws {
        defaultConfigUseCase.isOverriden = true

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        let title = scheduler.createObserver(String.self)
        let sectionItemsModels = scheduler.createObserver([SecItemsModel].self)

        output.title.drive(title).disposed(by: disposeBag)
        output.sectionItemsModels.drive(sectionItemsModels).disposed(by: disposeBag)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, ()),
            ]).bind(to: reloadPublisher)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(1, .init(key: "maxRetry", value: "20")),
                .next(2, .init(key: "maxRate", value: "0.99")),
                .next(3, .init(key: "apiURL", value: "https://stage.google.com")),
            ]).bind(to: updateValuePublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: OUTPUTS

        XCTAssertEqual(sectionItemsModels.events, [
            .next(0, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "10")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(1, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(2, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "0.99")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(3, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false)),
                    .textInput(.init(key: "apiURL", value: "https://stage.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "0.99")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
        ])

        XCTAssertEqual(MockConfigs.shared.maxRetry, 20)
        XCTAssertEqual(MockConfigs.shared.maxRate, 0.99)
    }

    func testTryToOverrideValueButNotOverridable() throws {
        defaultConfigUseCase.isOverriden = false

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        let title = scheduler.createObserver(String.self)
        let sectionItemsModels = scheduler.createObserver([SecItemsModel].self)

        output.title.drive(title).disposed(by: disposeBag)
        output.sectionItemsModels.drive(sectionItemsModels).disposed(by: disposeBag)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, ()),
            ]).bind(to: reloadPublisher)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(1, .init(key: "maxRetry", value: "20")),
                .next(2, .init(key: "maxRate", value: "0.99")),
            ]).bind(to: updateValuePublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: OUTPUTS

        XCTAssertEqual(sectionItemsModels.events, [
            .next(0, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: false),
                ]),
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

        defaultConfigUseCase.isOverriden = true

        let title = scheduler.createObserver(String.self)
        let sectionItemsModels = scheduler.createObserver([SecItemsModel].self)

        output.title.drive(title).disposed(by: disposeBag)
        output.sectionItemsModels.drive(sectionItemsModels).disposed(by: disposeBag)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, ()),
            ]).bind(to: reloadPublisher)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(1, .init(key: "maxRetry", value: "20")),
                .next(2, .init(key: "maxRate", value: "0.99")),
                .next(3, .init(key: "tags", value: "apple,banana")),
            ]).bind(to: updateValuePublisher)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(4, ()),
            ]).bind(to: resetPublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: - OUTPUTS

        XCTAssertEqual(sectionItemsModels.events, [
            .next(0, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "10")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(1, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(2, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "0.99")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(3, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true)),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "20")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "0.99")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
            .next(4, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true)), // uses remote
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com")), // uses remote
                    .textInput(.init(key: "apiVersion", value: "v1.2.3")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices)),
                    .textInput(.init(key: "maxRetry", value: "10")),
                    .textInput(.init(key: "threshold", value: "1")),
                    .textInput(.init(key: "rate", value: "2.5")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100")),
                    .textInput(.init(key: "maxRate", value: "1.0")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0")),
                    .textInput(.init(key: "width", value: "320.0")),
                ]),
            ]),
        ])
    }
}
