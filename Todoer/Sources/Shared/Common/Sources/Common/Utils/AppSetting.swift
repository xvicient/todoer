import UIKit

/// A property wrapper that provides persistent storage for app settings using UserDefaults
/// - Note: The wrapped value must be a type that UserDefaults can store
@propertyWrapper public struct AppSetting<Value> {
    /// The key used to store the value in UserDefaults
    let key: String
    /// The default value to return if no value is stored
    let defaultValue: Value
    /// The UserDefaults container to use for storage (defaults to .standard)
    var container: UserDefaults = .standard
    
    /// Creates a new AppSetting instance
    /// - Parameters:
    ///   - key: The key to use for storing the value in UserDefaults
    ///   - defaultValue: The default value to use if no value is stored
    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    /// The value stored in UserDefaults
    /// Gets the value from UserDefaults or returns the default value if none exists
    /// Sets the value in UserDefaults
    public var wrappedValue: Value {
        get { container.value(forKey: key) as? Value ?? defaultValue }
        set { container.setValue(newValue, forKey: key) }
    }
}
