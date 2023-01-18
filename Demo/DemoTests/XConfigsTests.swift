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
                .init(section: .group(""), items: [
                    .nameValue(name: "isOnboardingEnabled", value: "false"),
                    .nameValue(name: "apiURL", value: "https://prod.google.com"),
                    .nameValue(name: "apiVersion", value: "v1.2.3"),
                    .nameValue(name: "region", value: "north"),
                    .nameValue(name: "maxRetry", value: "10"),
                    .nameValue(name: "threshold", value: "1"),
                    .nameValue(name: "rate", value: "2.5"),
                    .nameValue(name: "tags", value: "apple,banana,mango"),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .nameValue(name: "maxScore", value: "100"),
                    .nameValue(name: "maxRate", value: "1.0"),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .nameValue(name: "height", value: "44.0"),
                    .nameValue(name: "width", value: "320.0"),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .nameValue(name: "Account Type", value: "Guest"),
                    .nameValue(name: "Contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}"),
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
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "10", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
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
                .next(4, .init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"2222 5678\"}")),
                .next(5, .init(key: "accountType", value: "2")),
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
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "10", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(1, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(2, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(3, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://stage.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(4, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://stage.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"2222 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(5, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://stage.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Admin", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"2222 5678\"}", displayName: "Contact")),
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
                .init(section: .group(""), items: [
                    .nameValue(name: "isOnboardingEnabled", value: "false"),
                    .nameValue(name: "apiURL", value: "https://prod.google.com"),
                    .nameValue(name: "apiVersion", value: "v1.2.3"),
                    .nameValue(name: "region", value: "north"),
                    .nameValue(name: "maxRetry", value: "10"),
                    .nameValue(name: "threshold", value: "1"),
                    .nameValue(name: "rate", value: "2.5"),
                    .nameValue(name: "tags", value: "apple,banana,mango"),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .nameValue(name: "maxScore", value: "100"),
                    .nameValue(name: "maxRate", value: "1.0"),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .nameValue(name: "height", value: "44.0"),
                    .nameValue(name: "width", value: "320.0"),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .nameValue(name: "Account Type", value: "Guest"),
                    .nameValue(name: "Contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}"),
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
                    .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "10", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(1, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(2, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(3, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")),
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "20", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "0.99", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
            .next(4, [
                .init(section: .main, items: [
                    .overrideConfig(title: "Override", value: true),
                    .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
                ]),
                .init(section: .group(""), items: [
                    .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")), // uses remote
                    .textInput(.init(key: "apiURL", value: "https://prod.google.com", displayName: "apiURL")), // uses remote
                    .textInput(.init(key: "apiVersion", value: "v1.2.3", displayName: "apiVersion")),
                    .optionSelection(.init(key: "region", value: "north", choices: regionChoices, displayName: "region")),
                    .textInput(.init(key: "maxRetry", value: "10", displayName: "maxRetry")),
                    .textInput(.init(key: "threshold", value: "1", displayName: "threshold")),
                    .textInput(.init(key: "rate", value: "2.5", displayName: "rate")),
                    .textInput(.init(key: "tags", value: "apple,banana,mango", displayName: "tags")),
                ]),
                .init(section: .group("Feature 1"), items: [
                    .textInput(.init(key: "maxScore", value: "100", displayName: "maxScore")),
                    .textInput(.init(key: "maxRate", value: "1.0", displayName: "maxRate")),
                ]),
                .init(section: .group("Feature 2"), items: [
                    .textInput(.init(key: "height", value: "44.0", displayName: "height")),
                    .textInput(.init(key: "width", value: "320.0", displayName: "width")),
                ]),
                .init(section: .group("Feature 3"), items: [
                    .optionSelection(.init(key: "accountType", value: "Guest", choices: [
                        .init(displayName: "Guest", value: "0"),
                        .init(displayName: "Member", value: "1"),
                        .init(displayName: "Admin", value: "2"),
                    ], displayName: "Account Type")),
                    .textInput(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"1234 5678\"}", displayName: "Contact")),
                ]),
            ]),
        ])
    }

    func testOutputAction() throws {
        defaultConfigUseCase.isOverriden = true

        let action = scheduler.createObserver(ViewModel.Action.self)

        output.action.drive(action).disposed(by: disposeBag)

        // MARK: INPUTS

        scheduler
            .createColdObservable([
                .next(0, .textInput(.init(key: "textInputA", value: "Text Input A", displayName: "Text Input A"))),
                .next(1, .toggle(.init(key: "toggleA", value: false, displayName: "Toggle A"))),
                .next(2, .optionSelection(.init(key: "options", value: "optionA", choices: [.init(displayName: "Option A", value: "optionA"), .init(displayName: "Option B", value: "optionB")], displayName: "Options"))),
                .next(3, .actionButton(title: "Reset", action: .showResetConfirmation("Do you want to reset?"))),
            ]).bind(to: selectItemPublisher)
            .disposed(by: disposeBag)

        scheduler
            .createColdObservable([
                .next(4, ()),
            ]).bind(to: dismissPublisher)
            .disposed(by: disposeBag)

        scheduler.start()

        // MARK: OUTPUTS

        XCTAssertEqual(action.events, [
            .next(0, .showTextInput(.init(key: "textInputA", value: "Text Input A", displayName: "Text Input A"))),
            .next(2, .showOptionSelection(.init(key: "options", value: "optionA", choices: [.init(displayName: "Option A", value: "optionA"), .init(displayName: "Option B", value: "optionB")], displayName: "Options"))),
            .next(3, .showResetConfirmation("Do you want to reset?")),
            .next(4, .dismiss),
        ])
    }
}
