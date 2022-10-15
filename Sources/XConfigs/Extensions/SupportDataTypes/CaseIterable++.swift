import Foundation

extension CaseIterable where Self: RawStringValueRepresentable {
    var allChoices: [String] {
        Self.allCases.map(\.rawString)
    }
}
