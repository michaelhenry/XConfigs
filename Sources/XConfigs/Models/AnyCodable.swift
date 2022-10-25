import Foundation

public struct AnyCodable<Value: Codable>: RawStringValueRepresentable, Codable {
    private let value: Value

    public init(_ value: Value) {
        self.value = value
    }

    public init?(rawString: String) {
        let decoder = JSONDecoder()
        guard let val = try? decoder.decode(Value.self, from: rawString.data(using: .utf8)!) else { return nil }
        self = AnyCodable(val)
    }

    public var rawString: String {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(value), let str = String(data: data, encoding: .utf8) else { return "" }
        return str
    }
}
