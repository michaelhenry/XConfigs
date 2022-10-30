<h1 align="center">🛠Configs</h1>
<p align="center">A quick, easy and elegant solution for your remote and dev configuration.</p>
<p align="center">
  <a href="https://github.com/michaelhenry/XConfigs/actions"><img alt="test" src="https://github.com/michaelhenry/XConfigs/workflows/test/badge.svg"></a>
  <a href="https://github.com/michaelhenry/XConfigs/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/michaelhenry/XConfigs.svg"/></a>
  <a href="https://developer.apple.com/swift"><img alt="Swift5" src="https://img.shields.io/badge/language-Swift5-orange.svg"></a>
  <a href="https://developer.apple.com"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"></a>
  <a href="LICENSE"><img alt="license" src="https://img.shields.io/badge/license-MIT-black.svg"></a>
</p>

---

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Example](#example)
- [Other Related](#other-related)
- [License](#license)

---

## Introduction

As part of software development process, we always need to see how our app will react depending on the different scenarios or configurations especially during testing even those features are not yet available in public. At the same time, it would be better if we some mechanism where we can immidiately turn off a certain features, or control some configurations remotely if there are something unexpected happened in our production build.

## Getting Started

Install using SPM

## Example

Similar with logger tool such as [swift-log](https://github.com/apple/swift-log), You can simply create a single global variable or just a singleton, as long as the it conforms to [XConfigSpec](Sources/XConfigs/Protocols/XConfigsSpec.swift) and then use the `@XConfig` property wrapper inside it.

If you have some custom datatype, you can simply conform them to `RawStringValueRepresentable`.

```swift
struct MockConfigs: XConfigSpec {

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

## Other Related

- [Firebase Remote Config](https://firebase.google.com/docs/remote-config), you can simply backed [XConfigs](https://github.com/michaelhenry/XConfigs) by FirebaseRemoteConfig by simply implmenting [KeyValueProvider](Sources/XConfigs/Protocols/KeyValueProvider.swift) protocol.


## LICENSE

MIT
