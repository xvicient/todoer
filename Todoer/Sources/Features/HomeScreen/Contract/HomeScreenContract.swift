import CoordinatorContract

/// Protocol defining the dependencies required by the Home Screen
/// This protocol ensures that the Home screen has access to the necessary navigation capabilities
public protocol HomeScreenDependencies {
    /// The coordinator API used for navigation and flow control
    var coordinator: CoordinatorApi { get }
}
