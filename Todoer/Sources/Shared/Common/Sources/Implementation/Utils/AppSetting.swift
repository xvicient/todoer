import UIKit

@propertyWrapper
public class AppSetting<Value: Codable> {
    private let key: String
    private let defaultValue: Value
    private let container: UserDefaults = .default

    public init(
        key: String,
        defaultValue: Value
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: Value {
        get {
            if let data = container.data(forKey: key),
                let value = try? JSONDecoder().decode(Value.self, from: data)
            {
                return value
            }
            return defaultValue
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                container.set(encoded, forKey: key)
            }
        }
    }
}
