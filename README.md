# RemoteConfig

A description of this package.

### Example

```swift
struct MockFeatureFlags: RemoteConfigSpec {

    static let `default` = Self()

    @RemoteConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @RemoteConfig(key: "apiHost", defaultValue: "https://google.com")
    var apiHost: String

    @RemoteConfig(key: "region", defaultValue: .north)
    var region: Region

    @RemoteConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @RemoteConfig(key: "rate", defaultValue: 2.5)
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

```
