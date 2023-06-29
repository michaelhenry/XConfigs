<h1 align="center">🛠Configs</h1>
<p align="center">A quick, simple and stylish solution for your remote and dev configurations.</p>
<p align="center">
  <a href="https://codecov.io/gh/michaelhenry/XConfigs"><img alt="codecov" src="https://codecov.io/gh/michaelhenry/XConfigs/branch/main/graph/badge.svg?token=WLH8VVA19I"/></a>
  <a href="https://github.com/michaelhenry/XConfigs/actions"><img alt="test" src="https://github.com/michaelhenry/XConfigs/actions/workflows/test.yml/badge.svg"></a>
  <a href="https://github.com/michaelhenry/XConfigs/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/michaelhenry/XConfigs.svg"/></a>
  <a href="https://developer.apple.com/swift"><img alt="Swift5.7" src="https://img.shields.io/badge/language-Swift5.7-orange.svg"></a>
  <a href="https://developer.apple.com"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"></a>
  <a href="https://developer.apple.com"><img alt="Support" src="https://img.shields.io/badge/support-iOS%2011+-red.svg"></a>
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-black.svg"></a>
</p>

---

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [How to use](#how-to-use)
- [Example](#example)
- [Other Related](#other-related)
- [License](#license)

---

## Introduction

As part of software development process, we always need to see how our app will react depending on the different scenarios or configurations especially during testing. At the same time, it would be better if we can control some of app configurations on the fly, especially if there are unexpected things happened in our production environment, we can immediately enable or disable certain app functionality.

## Getting Started

Install using SPM

```swift
.package(url: "https://github.com/michaelhenry/XConfigs", .upToNextMinor(from: "1.0.0")),
```

## How to use

```swift
let kvProvider = SampleKeyValueProvider()

// Register the AppConfigs and set which keyValueProvider and option to use. Note that `.allowInAppModification(InAppModificationOption)` option accepts a `KeyValueStore`.
XConfigs.configure(with: AppConfigs.self, keyValueProvider: kvProvider, option: .allowInAppModification(.init(store: UserDefaults.standard)))
```

Please note that on production build, it is recommend that the in-app modification is disabled (`option is set to readonly`), so XConfigs will just use either the value from the **keyValueProvider** or the default value assigned inside the property wrapper as fallback.

Eg.

```swift
#if DEBUG
    XConfigs.configure(with: MockConfigs.self, keyValueProvider: kvProvider, option: .allowInAppModification(.init(store: UserDefaults.standard)))
#else
    XConfigs.configure(with: MockConfigs.self, keyValueProvider: kvProvider, option: .readonly)
#endif
```

## 📄 Documentation

Please refer to [XConfigs's docs](https://michaelhenry.github.io/XConfigs/documentation/xconfigs/).

## Example

Similar with logger tool such as [swift-log](https://github.com/apple/swift-log), You can simply create a single global variable or just a singleton, as long as the it conforms to [XConfigSpec](Sources/XConfigs/Protocols/XConfigsSpec.swift)ification and then use the `@XConfig` property wrapper inside it.

If you have some custom datatype, you can simply conform them to `RawStringValueRepresentable`. So the key thing is as long as a value can be represented as a string, it should be fine.

```swift
struct AppConfigs: XConfigSpec {

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiURL", defaultValue: URL(string: "https://google.com")!)
    var apiURL: URL

    @XConfig(key: "region", defaultValue: .north)
    var region: Region

    @XConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @XConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @XConfig(key: "rate", defaultValue: 2.5)
    var rate: Double
}

enum Region: String, CaseIterable, RawStringValueRepresentable {
    case north
    case south
    case east
    case west
}
```

For the complete example, please refer to the [Demo](Demo) project which auto-generated the screen(below) using the [AppConfigs.swift](https://github.com/michaelhenry/XConfigs/blob/main/Demo/Demo/AppConfigs.swift) config specification.

https://user-images.githubusercontent.com/717992/213901399-d4429d63-83fb-4770-ac9c-a016e2128084.mp4

https://github.com/michaelhenry/XConfigs/assets/717992/2b1ef692-647e-4fb0-aea4-aa4be25e9b31

## Other Related

### [Firebase Remote Config](https://firebase.google.com/docs/remote-config)

You can backed [XConfigs](https://github.com/michaelhenry/XConfigs) by [FirebaseRemoteConfig](https://firebase.google.com/docs/remote-config) by simply implementing the [KeyValueProvider](Sources/XConfigs/Protocols/KeyValueProvider.swift) protocol.


Example:

```swift
import FirebaseRemoteConfig

struct FirebaseKeyValueProvider: KeyValueProvider {

    private let remoteConfig: RemoteConfig = {
        let rconfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        rconfig.configSettings = settings
        return rconfig
    }()
    
    // Please refer to https://firebase.google.com/docs/remote-config/get-started?platform=ios
    func fetch() {
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    // ...
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }

    // XConfigs KeyValueProvider protocol
    func get<Value>(for key: String) -> Value? where Value : RawStringValueRepresentable {
        guard let rawValue = remoteConfig.configValue(forKey: key).stringValue, let value = Value(rawString: rawValue) else { return nil }
        return value
    }
}

```

## LICENSE

MIT
