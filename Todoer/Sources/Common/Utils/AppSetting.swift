import UIKit

@propertyWrapper struct AppSetting<Value> {
	let key: String
	let defaultValue: Value
	var container: UserDefaults = .standard

	var wrappedValue: Value {
		get { container.value(forKey: key) as? Value ?? defaultValue }
		set { container.setValue(newValue, forKey: key) }
	}
}
