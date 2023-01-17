import Foundation

struct Choice: Hashable {
    let displayName: String
    let value: String
}

struct OptionSelectionModel: Hashable {
    let key: String
    let value: String
    let choices: [Choice]
    let displayName: String
}
