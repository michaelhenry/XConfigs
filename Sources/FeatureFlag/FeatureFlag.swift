import Foundation
import SwiftSyntax

protocol FeatureFlagValueRepresentable {}

protocol FeatureFlagStore {
    func get<Value: FeatureFlagValueRepresentable>(key: String) -> Value?
    func set<Value: FeatureFlagValueRepresentable>(object: Value, for key: String)
}

extension UserDefaults: FeatureFlagStore {
    func get<Value>(key: String) -> Value? where Value: FeatureFlagValueRepresentable {
        object(forKey: key) as? Value
    }

    func set<Value>(object: Value, for key: String) where Value: FeatureFlagValueRepresentable {
        set(object, forKey: key)
    }
}

class FeatureFlagManager {
    static let manager = FeatureFlagManager()
    var store: FeatureFlagStore = UserDefaults.standard
}

@propertyWrapper
struct FeatureFlag<Value: FeatureFlagValueRepresentable> {
    var key: String
    var defaultValue: Value
    var wrappedValue: Value {
        get { FeatureFlagManager.manager.store.get(key: key) ?? defaultValue }
        set { FeatureFlagManager.manager.store.set(object: newValue, for: key) }
    }

    init(key: String, defaultValue: Value) {
        print("INIT", key)
        self.key = key
        self.defaultValue = defaultValue
    }
}

extension Bool: FeatureFlagValueRepresentable {}

enum FeatureFlags {
    @FeatureFlag(key: "isOnboardingEnabled", defaultValue: false)
    static var isOnboardingEnabled: Bool
}

///// AddOneToIntegerLiterals will visit each token in the Syntax tree, and
///// (if it is an integer literal token) add 1 to the integer and return the
///// new integer literal token.
// class AddOneToIntegerLiterals: SyntaxRewriter {
//  override func visit(_ token: TokenSyntax) -> Syntax {
//    // Only transform integer literals.
//    guard case .integerLiteral(let text) = token.tokenKind else {
//      return Syntax(token)
//    }
//
//    // Remove underscores from the original text.
//    let integerText = String(text.filter { ("0"..."9").contains($0) })
//
//    // Parse out the integer.
//    let int = Int(integerText)!
//
//    // Create a new integer literal token with `int + 1` as its text.
//    let newIntegerLiteralToken = token.withKind(.integerLiteral("\(int + 1)"))
//
//    // Return the new integer literal.
//    return Syntax(newIntegerLiteralToken)
//  }
// }
//
// let file = CommandLine.arguments[1]
// let url = URL(fileURLWithPath: file)
// let sourceFile = try SyntaxParser.parse(url)
// let incremented = AddOneToIntegerLiterals().visit(sourceFile)
// print(incremented)
