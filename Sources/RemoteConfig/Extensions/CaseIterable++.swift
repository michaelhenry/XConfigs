import Foundation

extension CaseIterable where Self: RawStringRepresentable {
    var allChoices: [String] {
        Self.allCases.compactMap(\.rawString)
    }
}
