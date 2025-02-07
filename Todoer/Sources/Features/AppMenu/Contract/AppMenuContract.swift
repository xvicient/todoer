import SwiftUI
import CoordinatorContract

/// Namespace for app menu-related components
public struct AppMenu {}

/// Protocol defining the dependencies required by the app menu
/// This protocol ensures that the app menu has access to the necessary navigation capabilities
public protocol AppMenuDependencies {
    /// The coordinator API used for navigation and flow control
    var coordinator: CoordinatorApi { get }
}
