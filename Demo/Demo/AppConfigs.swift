import Foundation
import XConfigs

struct AppConfigs: XConfigsSpec {
    static let shared = Self()

    @XConfig(key: "environment", defaultValue: .dev)
    var environment: Environment

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiURL", defaultValue: URL(string: "https://dev.google.com")!)
    var apiURL: URL

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

    // MARK: - Feature 1

    @XConfig(key: "maxScore", defaultValue: 100, group: .feature1)
    var maxScore: Int

    @XConfig(key: "maxRate", defaultValue: 1.0, group: .feature1)
    var maxRate: Double

    // MARK: - Feature 2

    @XConfig(key: "maxHeight", defaultValue: 100, group: .feature2)
    var maxHeight: Double

    @XConfig(key: "maxWidth", defaultValue: 300.5, group: .feature2)
    var maxWidth: Double

    // MARK: - Custom Data Types

    @XConfig(key: "contact", defaultValue: .default, group: .otherDataTypes)
    var contactInfo: Contact

    @XConfig(key: "place", defaultValue: Place(city: "Tokyo", country: "Japan"), group: .otherDataTypes)
    var place: Place

    @XConfig(key: "favoriteFruits", defaultValue: ["apple", "banana", "mango", "grape", "strawberry"], group: .otherDataTypes)
    var favoriteFruits: [String]

    @XConfig(key: "favouriteNumbers", defaultValue: [1, 2, 3, 4, 5], group: .otherDataTypes)
    var favouriteNumbers: [Int]

    @XConfig(key: "nestedInfo", defaultValue: NestedInfo(), group: .otherDataTypes)
    var nestedInfo: NestedInfo

    @XConfig(key: "accountType", defaultValue: .guest, group: .otherDataTypes)
    var accountType: AccountType

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
}

// Wanna make it more readable instead of just showing integer values?
// Then conform to `CustomStringConvertible`
enum AccountType: Int, CaseIterable, RawStringValueRepresentable, CustomStringConvertible {
    case guest = 0
    case member = 1
    case admin = 2

    var description: String {
        switch self {
        case .guest:
            return "Guest"
        case .member:
            return "Member"
        case .admin:
            return "Admin"
        }
    }
}

enum Environment: String, RawStringValueRepresentable, CaseIterable {
    case dev
    case stage
    case prod
}

struct Contact: RawStringValueRepresentable {
    let name: String
    let phoneNumber: String

    static let `default` = Contact(name: "Name", phoneNumber: "1234 5678")
}

struct Place: RawStringValueRepresentable {
    let city: String
    let country: String
}

struct NestedInfo: RawStringValueRepresentable {
    var contact = Contact.default
    var place = Place(city: "Melbourne", country: "Australia")
    var favouriteNumbers = [1, 2, 3, 4, 5, 6]
    var favouriteFoods = ["cake", "bread", "fish", "meat"]
    var someKeyValues = ["name": "Kel", "job": "programmer"]
}
