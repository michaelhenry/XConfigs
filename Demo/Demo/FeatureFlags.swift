import Foundation
import XConfigs

struct FeatureFlags: XConfigsSpec {
    static let shared = Self()

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiHost", defaultValue: URL(string: "https://www.google.com")!)
    var apiHost: URL

    @XConfig(key: "apiVersion", defaultValue: "v1.2.3")
    var apiVersion: String

    @XConfig(key: "region", defaultValue: .north)
    var region: Region

    @XConfig(key: "maxRetry", defaultValue: 10)
    var maxRetry: Int

    @XConfig(key: "threshold", defaultValue: 1)
    var threshold: Int

    @XConfig(key: "rate", defaultValue: 2.5)
    var rate: Double

    @XConfig(key: "maxScore", defaultValue: 100, group: .feature1)
    var maxScore: Int

    @XConfig(key: "maxRate", defaultValue: 1.0, group: .feature2)
    var maxRate: Double

    @XConfig(key: "maxHeight", defaultValue: 100, group: .feature2)
    var maxHeight: Double

    @XConfig(key: "maxWidth", defaultValue: 300.5, group: .feature2)
    var maxWidth: Double

    // Custom Objects or Data Types
    // Either:

    // Conform to `RawStringValueRepresentable`
    @XConfig(key: "contact", defaultValue: .default, group: .otherDataTypes)
    var contactInfo: Contact

    // OR:

    // Wrap the codable object inside `AnyCodable`
    @XConfig(key: "place", defaultValue: Place(city: "Tokyo", country: "Japan"), group: .otherDataTypes)
    var place: Place

    @XConfig(key: "favoriteFruits", defaultValue: [String](["apple", "banana", "mango", "grape", "strawberry"]), group: .otherDataTypes)
    var favoriteFruits: [String]

    @XConfig(key: "favouriteNumbers", defaultValue: [Int]([1, 2, 3, 4, 5]), group: .otherDataTypes)
    var favouriteNumbers: [Int]

    @XConfig(key: "nestedInfo", defaultValue: NestedInfo(), group: .otherDataTypes)
    var nestedInfo: NestedInfo

    // So the key is: as long as you can represent it as string, it should be fine.
}

extension XConfigGroup {
    static let feature1 = Self(name: "Feature 1", sort: 1)
    static let feature2 = Self(name: "Feature 2", sort: 2)
    static let otherDataTypes = Self(name: "Other Data Types", sort: 3)
}

enum Region: String, CaseIterable, RawStringValueRepresentable {
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

struct Contact: Codable, RawStringValueRepresentable {
    let name: String
    let phoneNumber: String

    init(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }

    static let `default` = Contact(name: "Name", phoneNumber: "1234 5678")
}

struct Place: Codable, RawStringValueRepresentable {
    let city: String
    let country: String
}

struct NestedInfo: Codable, RawStringValueRepresentable {
    var contact = Contact.default
    var place = Place(city: "Melbourne", country: "Australia")
    var favouriteNumbers = [1, 2, 3, 4, 5, 6]
    var favouriteFoods = ["cake", "bread", "fish", "meat"]
    var someKeyValues = ["name": "Kel", "job": "programmer"]
}