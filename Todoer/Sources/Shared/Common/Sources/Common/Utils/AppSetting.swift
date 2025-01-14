import UIKit

@propertyWrapper public struct AppSetting<Value> {
	let key: String
	let defaultValue: Value
	var container: UserDefaults = .standard
    
    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: Value {
		get { container.value(forKey: key) as? Value ?? defaultValue }
		set { container.setValue(newValue, forKey: key) }
	}
}
