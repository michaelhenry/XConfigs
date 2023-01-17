import XConfigs
import XCTest

struct MockConfigs: XConfigsSpec {
    static let shared = Self()

    @XConfig(key: "isOnboardingEnabled", defaultValue: false)
    var isOnboardingEnabled: Bool

    @XConfig(key: "apiURL", defaultValue: URL(string: "https://prod.google.com")!)
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

    @XConfig(key: "tags", defaultValue: ["apple", "banana", "mango"])
    var favoriteFruits: [String]

    @XConfig(key: "maxScore", defaultValue: 100, group: .feature1)
    var maxScore: Int

    @XConfig(key: "maxRate", defaultValue: 1.0, group: .feature1)
    var maxRate: Double

    @XConfig(key: "height", defaultValue: 44, group: .feature2)
    var height: Double

    @XConfig(key: "width", defaultValue: 320, group: .feature2)
    var width: Double

    @XConfig(key: "accountType", displayName: "Account Type", defaultValue: .guest, group: .feature3)
    var accountType: AccountType

    @XConfig(key: "contact", displayName: "Contact", defaultValue: .default, group: .feature3)
    var contact: Contact
}

extension XConfigGroup {
    static let feature1 = Self(name: "Feature 1", sort: 1)
    static let feature2 = Self(name: "Feature 2", sort: 2)
    static let feature3 = Self(name: "Feature 3", sort: 3)
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

struct Contact: RawStringValueRepresentable {
    let name: String
    let phoneNumber: String

    static let `default` = Contact(name: "Ken", phoneNumber: "1234 5678")
}
