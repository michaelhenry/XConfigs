import Foundation

enum FeatureFlags {
    @FeatureFlag(key: "isOnboardingEnabled", defaultValue: false)
    static var isOnboardingEnabled: Bool

    @FeatureFlag(key: "apiHost", defaultValue: "https://google.com")
    static var apiHost: String

    @FeatureFlag(key: "dataType", defaultValue: DataType.one)
    static var dataType: DataType
}

enum DataType: FeatureFlagValueRepresentable {
    case one
    case two
}