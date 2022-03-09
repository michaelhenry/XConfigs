import XCTest
import SwiftSyntax
@testable import FeatureFlag

final class FeatureFlagTests: XCTestCase {
    let mockUserDefault = UserDefaults.standard

    func testDefault() throws {
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertFalse(FeatureFlags.isOnboardingEnabled)
    }

    func testHappyDefault() throws {
        mockUserDefault.set(object: true, for: "isOnboardingEnabled")
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertTrue(FeatureFlags.isOnboardingEnabled)
    }

    func testSetAndGetValue() throws {
        FeatureFlagManager.manager.store = mockUserDefault
        XCTAssertFalse(FeatureFlags.isOnboardingEnabled)
        FeatureFlags.isOnboardingEnabled = true
        XCTAssertTrue(FeatureFlags.isOnboardingEnabled)
        XCTAssertTrue(mockUserDefault.bool(forKey: "isOnboardingEnabled"))
    }

    override func tearDown() {
        super.tearDown()
        // Clear store
        mockUserDefault.dictionaryRepresentation().forEach {
            mockUserDefault.removeObject(forKey: $0.key)
        }
    }



    func testSyntaxRewriter() throws {
        let testSource = """

            import Foundation

            enum FeatureFlags {
                @FeatureFlag(key: "isOnboardingEnabled", defaultValue: false)
                static var isOnboardingEnabled: Bool

                @FeatureFlag(key: "apiHost", defaultValue: "https://google.com")
                static var apiHost: String

                @FeatureFlag(key: "dataType", defaultValue: DataType.one)
                static var dataType: DataType
            }
        """
        let sourceFile = try SyntaxParser.parse(source: testSource)
        print(sourceFile)
        let visitor = FeatureFlagsRewriter()
        let result = visitor.visit(sourceFile)
        var contents: String = ""
        result.write(to: &contents)
        print("RESULT content\n\n", result)
    }
}

 class FeatureFlagsRewriter: SyntaxRewriter {

    override func visit(_ token: TokenSyntax) -> Syntax {

        if token.tokenKind == .atSign, token.nextToken?.tokenKind == .identifier("FeatureFlag") {
            // Found @FeatureFlag
            // look up for key
            if case let .stringSegment(key) = token.nextToken?.nextToken?.nextToken?.nextToken?.nextToken?.nextToken?.tokenKind {
                print("KEY IS", key)
            }

            // Look up for key
            var keyValue: String?
            var keyFound = false
            var nextToken = token.nextToken
            while keyValue == nil && nextToken != nil {
                 if nextToken?.tokenKind == .identifier("key") {
                    keyFound = true
                }

                nextToken = nextToken?.nextToken

                if keyFound {
                    if case let .stringSegment(k) = nextToken?.tokenKind {
                        keyValue = k
                    }
                }
            }


            // Look up for defaultValue
            var defaultValue: String?
            var defaultValueFound = false
            nextToken = nextToken?.nextToken
            while defaultValue == nil && nextToken != nil {
                 if nextToken?.tokenKind == .identifier("defaultValue") {
                    defaultValueFound = true
                }

                nextToken = nextToken?.nextToken

                if defaultValueFound {
                    if case let .stringSegment(k) = nextToken?.tokenKind {
                        defaultValue = k
                    }
                }
            }
            print("""
            #######################################
            KEY: \(keyValue ?? "")
            DEFAULT: \(defaultValue ?? "")
            #######################################
            """)
        }
        print("TOKEN", token.text, token.tokenKind)
        return Syntax(token)
    }
}