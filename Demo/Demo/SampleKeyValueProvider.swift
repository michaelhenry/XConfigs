import Foundation
import XConfigs

final class SampleKeyValueProvider: KeyValueProvider {
    private let remoteKeyValuesURL = URL(string: "https://gist.githubusercontent.com/michaelhenry/57809ecedc24d9de8936078a9f0c12f1/raw/c87824ffdf34df63cae2917774dda1d4d012a168/remoteKeyValues.json")!
    private var keyValues: [String: String] = [:]

    func download(completion: @escaping ((Bool) -> Void)) {
        URLSession.shared.dataTask(with: URLRequest(url: remoteKeyValuesURL)) { [weak self] data, _, _ in
            guard let data, let self else {
                completion(false)
                return
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                self.keyValues = jsonObject.reduce(into: [String: String]()) {
                    $0[$1.key] = String(describing: $1.value)
                    print($1.key, $1.value)
                }
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func get<Value: RawStringValueRepresentable>(for key: String) -> Value? {
        guard let rawStringValue = keyValues[key] else { return nil }
        return Value(rawString: rawStringValue)
    }
}
