import Combine
import XCTest
@testable import Demo
@testable import XConfigs

final class XConfigsTests: XCTestCase {
    typealias ViewModel = XConfigsViewModel
    typealias SecItemsModel = SectionItemsModel<ViewModel.Section, ViewModel.Item>
    private var subscriptions = Set<AnyCancellable>()
    private var provider: MockKeyValueProvider!
    private var store: MockKeyValueStore!

    var searchPublisher = CurrentValueSubject<String, Never>("")
    private var reloadPublisher = PassthroughSubject<Void, Never>()
    private var updateValuePublisher = PassthroughSubject<KeyValue, Never>()
    private var overrideConfigPublisher = PassthroughSubject<Bool, Never>()
    private var resetPublisher = PassthroughSubject<Void, Never>()
    private var selectItemPublisher = PassthroughSubject<ViewModel.Item, Never>()
    private var dismissPublisher = PassthroughSubject<Void, Never>()

    private var output: XConfigsViewModel.Output!

    private let regionChoices = ["north", "south", "east", "west"].map { Choice(displayName: $0, value: $0) }
    private let envChoices = ["dev", "stage", "prod"].map { Choice(displayName: $0, value: $0) }

    override func setUpWithError() throws {
        try super.setUpWithError()
        subscriptions = .init()
        provider = MockKeyValueProvider()
        store = MockKeyValueStore()
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: provider, option: .allowInAppModification(.init(store: store, updateDelegate: self)))

        searchPublisher = .init("")
        reloadPublisher = .init()
        updateValuePublisher = .init()
        overrideConfigPublisher = .init()
        resetPublisher = .init()
        selectItemPublisher = .init()
        dismissPublisher = .init()

        let viewModel = XConfigsViewModel()
        output = viewModel.transform(input: .init(
            searchPublisher: searchPublisher.eraseToAnyPublisher(),
            reloadPublisher: reloadPublisher.eraseToAnyPublisher(),
            updateValuePublisher: updateValuePublisher.eraseToAnyPublisher(),
            overrideConfigPublisher: overrideConfigPublisher.eraseToAnyPublisher(),
            resetPublisher: resetPublisher.eraseToAnyPublisher(),
            selectItemPublisher: selectItemPublisher.eraseToAnyPublisher(),
            dismissPublisher: dismissPublisher.eraseToAnyPublisher()
        ))
    }

    func testTitles() throws {
        var title = ""
        var searchPlaceholderTitle = ""
        output.title.sink { title = $0 }.store(in: &subscriptions)
        output.searchPlaceholderTitle.sink { searchPlaceholderTitle = $0 }.store(in: &subscriptions)

        XCTAssertEqual(title, NSLocalizedString("🛠Configs", comment: ""))
        XCTAssertEqual(searchPlaceholderTitle, NSLocalizedString("Search", comment: ""))
    }

    func testInAppModificationEnabledWhenOptionIsReadonly() throws {
        XConfigs.configure(with: MockConfigs.self, keyValueProvider: provider, option: .readonly)
        XCTAssertThrowsError(try XConfigs.setInAppModification(enable: true))
    }

    func testInAppModificationDisabled() throws {
        try XConfigs.setInAppModification(enable: false)
        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send(())

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: false),
            ]),
            .init(section: .group(""), items: [
                .nameValue(name: "environment", value: "dev"),
                .nameValue(name: "isOnboardingEnabled", value: "false"),
                .nameValue(name: "apiURL", value: "https://dev.google.com"),
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
        ])
    }

    func testFilter() throws {
        try XConfigs.setInAppModification(enable: false)
        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send(())
        searchPublisher.send("env")

        // MARK: OUTPUTS

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: false),
            ]),
            .init(section: .group(""), items: [
                .nameValue(name: "environment", value: "dev"),
                .nameValue(name: "isOnboardingEnabled", value: "false"),
                .nameValue(name: "apiURL", value: "https://dev.google.com"),
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
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: false),
            ]),
            .init(section: .group(""), items: [
                .nameValue(name: "environment", value: "dev"),
            ]),
        ])
    }

    func testInAppModificationEnabled() throws {
        try XConfigs.setInAppModification(enable: true)

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send()

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])
    }

    func testhOverridingUpdateValues() throws {
        try XConfigs.setInAppModification(enable: true)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send()
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))
        updateValuePublisher.send(.init(key: "apiURL", value: "https://stage.google.com"))
        updateValuePublisher.send(.init(key: "contact", value: "{\"name\":\"Ken\",\"phoneNumber\":\"2222 5678\"}"))
        updateValuePublisher.send(.init(key: "accountType", value: "2"))

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])

        XCTAssertEqual(sectionItemsModels[2], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])

        XCTAssertEqual(sectionItemsModels[3], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
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
        ])

        XCTAssertEqual(sectionItemsModels[4], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
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
        ])

        XCTAssertEqual(sectionItemsModels[5], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
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
        ])

        XCTAssertEqual(MockConfigs.shared.maxRetry, 20)
        XCTAssertEqual(MockConfigs.shared.maxRate, 0.99)
    }

    func testTryToOverrideValueButNotOverridable() throws {
        try XConfigs.setInAppModification(enable: false)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send()
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: false),
            ]),
            .init(section: .group(""), items: [
                .nameValue(name: "environment", value: "dev"),
                .nameValue(name: "isOnboardingEnabled", value: "false"),
                .nameValue(name: "apiURL", value: "https://dev.google.com"),
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
        ])

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)
    }

    func testhOverridingUpdateValuesThenReset() throws {
        // use this value instead of the assigned defaultValue
        provider.mock(next: [
            "isOnboardingEnabled": true,
            "apiURL": "https://dev.google.com",
        ])

        try XConfigs.setInAppModification(enable: true)

        XCTAssertEqual(MockConfigs.shared.maxRetry, 10)
        XCTAssertEqual(MockConfigs.shared.maxRate, 1.0)

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send()
        updateValuePublisher.send(.init(key: "maxRetry", value: "20"))
        updateValuePublisher.send(.init(key: "maxRate", value: "0.99"))
        updateValuePublisher.send(.init(key: "tags", value: "apple,banana"))
        resetPublisher.send()

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])

        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])
        XCTAssertEqual(sectionItemsModels[2], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])
        XCTAssertEqual(sectionItemsModels[3], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])

        XCTAssertEqual(sectionItemsModels[4], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: true, displayName: "isOnboardingEnabled")), // uses remote
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")), // uses remote
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
        ])
    }

    func testOutputAction() throws {
        try XConfigs.setInAppModification(enable: true)

        var actions = [ViewModel.Action]()
        output.action.sink { action in
            actions.append(action)
        }
        .store(in: &subscriptions)

        selectItemPublisher.send(.textInput(.init(key: "textInputA", value: "Text Input A", displayName: "Text Input A")))
        selectItemPublisher.send(.toggle(.init(key: "toggleA", value: false, displayName: "Toggle A")))
        selectItemPublisher.send(.optionSelection(.init(key: "options", value: "optionA", choices: [.init(displayName: "Option A", value: "optionA"), .init(displayName: "Option B", value: "optionB")], displayName: "Options")))
        selectItemPublisher.send(.actionButton(title: "Reset", action: .showResetConfirmation("Do you want to reset?")))

        dismissPublisher.send()

        XCTAssertEqual(actions[0], .showTextInput(.init(key: "textInputA", value: "Text Input A", displayName: "Text Input A")))
        XCTAssertEqual(actions[1], .showOptionSelection(.init(key: "options", value: "optionA", choices: [.init(displayName: "Option A", value: "optionA"), .init(displayName: "Option B", value: "optionB")], displayName: "Options")))
        XCTAssertEqual(actions[2], .showResetConfirmation("Do you want to reset?"))
        XCTAssertEqual(actions[3], .dismiss)
    }

    func testUpdateDelegate() throws {
        try XConfigs.setInAppModification(enable: true)

        var sectionItemsModels = [[SectionItemsModel<ViewModel.Section, ViewModel.Item>]]()
        output.sectionItemsModels.sink { secItem in
            sectionItemsModels.append(secItem)
        }
        .store(in: &subscriptions)

        reloadPublisher.send()
        updateValuePublisher.send(.init(key: "environment", value: "stage"))

        XCTAssertEqual(sectionItemsModels[0], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "dev", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://dev.google.com", displayName: "apiURL")),
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
        ])
        XCTAssertEqual(sectionItemsModels[1], [
            .init(section: .main, items: [
                .inAppModification(title: "Enable In-app modification?", value: true),
                .actionButton(title: "Reset", action: .showResetConfirmation("Are you sure you want to reset these values?")),
            ]),
            .init(section: .group(""), items: [
                .optionSelection(.init(key: "environment", value: "stage", choices: envChoices, displayName: "environment")),
                .toggle(.init(key: "isOnboardingEnabled", value: false, displayName: "isOnboardingEnabled")),
                .textInput(.init(key: "apiURL", value: "https://stage.google.com", displayName: "apiURL")),
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
        ])
    }
}

extension XConfigsTests: InAppConfigUpdateDelegate {
    func configWillUpdate(key: String, value: RawStringValueRepresentable, store: KeyValueStore) {
        switch key {
        case "environment":
            store.set(value: "https://\(value.rawString).google.com", for: "apiURL")
        default:
            break
        }
    }
}
