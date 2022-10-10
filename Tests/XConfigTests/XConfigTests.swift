import XCTest
@testable import XConfig

final class XConfigTests: XCTestCase {
    func testRegistration() throws {
        let useCase = XConfigUseCase.shared
        let mockLocalStore = MockLocalKVStore()
        let remoteKVProvider = MockRemoteKVProvider()
        useCase.update(localKVStore: { mockLocalStore })
        useCase.update(remoteKVProvider: { remoteKVProvider })
        let vm = XConfigViewModel(useCase: useCase, spec: MockConfigs.self)

        XCTAssertEqual(vm.sectionItemsModels, [
            .init(section: .main, items: [
                .toggle(.init(key: "isOnboardingEnabled", value: false)),
                .textInput(.init(key: "apiHost", value: "https://google.com")),
                .optionSelection(.init(key: "region", value: "north", choices: ["north", "south", "east", "west"])),
                .textInput(.init(key: "maxRetry", value: "10")),
                .textInput(.init(key: "threshold", value: "1")),
                .textInput(.init(key: "rate", value: "2.5")),
            ]),
        ])
    }
}

struct MockConfigs: XConfigSpec {
    static let `default` = Self()

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiHost", defaultValue: "https://google.com")
    var apiHost: String

    @XConfig(key: "region", defaultValue: .north)
    var region: Region

    @XConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @XConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @XConfig(key: "rate", defaultValue: 2.5)
    var rate: Double
}

enum Region: String, CaseIterable, RawStringRepresentable {
    case north
    case south
    case east
    case west

    init(rawString: String) {
        self = .init(rawValue: rawString) ?? .north
    }

    var rawString: String {
        rawValue
    }
}

class MockLocalKVStore: LocalKeyValueStore {
    func get<Value>(key _: String) -> Value? {
        nil
    }

    func set<Value>(value _: Value, for _: String) {}

    func deleteAll() {}
}

class MockRemoteKVProvider: RemoteKeyValueProvider {
    func get<Value>(for _: String) -> Value? {
        nil
    }
}
