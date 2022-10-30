import Foundation

public protocol RawStringValueRepresentable {
    var rawString: String { get }

    init?(rawString: String)
}

// MARK: - Bool + RawStringValueRepresentable

extension Bool: RawStringValueRepresentable {
    public var rawString: String {
        "\(self)"
    }

    public init(rawString: String) {
        self = ["1", "true"].contains(rawString)
    }
}

// MARK: - Int + RawStringValueRepresentable

extension Int: RawStringValueRepresentable {} // Codable + RawStringValueRepresentable can pick this up

// MARK: - Double + RawStringValueRepresentable

extension Double: RawStringValueRepresentable { // Codable + RawStringValueRepresentable can pick this up BUT it has some minor issue with the accuracy of the floating point
    public var rawString: String {
        "\(self)"
    }

    public init?(rawString: String) {
        guard let val = Double(rawString) else { return nil }
        self = val
    }
}

// MARK: - String + RawStringValueRepresentable

extension String: RawStringValueRepresentable { // Codable + RawStringValueRepresentable can pick this up BUT JSONDecoder is wrapping string inside quotes.
    public var rawString: String {
        self
    }

    public init(rawString: String) {
        self = rawString
    }
}

// MARK: - URL + RawStringValueRepresentable

extension URL: RawStringValueRepresentable {
    public var rawString: String {
        absoluteString
    }

    public init?(rawString: String) {
        guard let url = URL(string: rawString) else { return nil }
        self = url
    }
}

// MARK: - CaseIteratable + RawStringValueRepresentable

extension CaseIterable where Self: RawStringValueRepresentable {
    var allChoices: [String] {
        Self.allCases.map(\.rawString)
    }
}

// MARK: - Codable + RawStringValueRepresentable

public extension RawStringValueRepresentable where Self: Codable {
    init?(rawString: String) {
        let decoder = JSONDecoder()
        guard let data = rawString.data(using: .utf8), let val = try? decoder.decode(Self.self, from: data) else { return nil }
        self = val
    }

    var rawString: String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self), let str = String(data: data, encoding: .utf8) else { return "" }
        return str
    }
}

// MARK: - Array + RawStringValueRepresentable

extension Array: RawStringValueRepresentable where Element: RawStringValueRepresentable {
    public var rawString: String {
        map(\.rawString).joined(separator: ",")
    }

    public init?(rawString: String) {
        self = rawString.split(separator: ",").compactMap {
            Element(rawString: String($0))
        }
    }
}
