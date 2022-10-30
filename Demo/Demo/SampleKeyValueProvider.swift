import Foundation
import XConfigs

final class SampleKeyValueProvider: KeyValueProvider {
    private let remoteKeyValuesURL = URL(string: "https://gist.githubusercontent.com/michaelhenry/57809ecedc24d9de8936078a9f0c12f1/raw/8103b6cdd9cb7930ca05ca4a407d9c1e51839702/remoteKeyValues.json")!
    private var keyValues: [String: String] = [:]

    func download() {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: self.remoteKeyValuesURL)
                print("DATA", String(data: data, encoding: .utf8)!)
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                print("JSON", jsonObject)
                self.keyValues = jsonObject.reduce(into: [String: String]()) {
                    $0[$1.key] = String(describing: $1.value)
                }
            } catch {
                print("ERROR", error)
            }
        }
    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawStringValue = keyValues[key] else { return nil }
        return Value(rawString: rawStringValue)
    }
}
