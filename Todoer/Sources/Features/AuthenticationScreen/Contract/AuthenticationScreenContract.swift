import CoordinatorContract

/// Contract defining dependencies and data types for the Authentication feature
public protocol AuthenticationScreenDependencies {
    /// Coordinator for handling navigation
    var coordinator: CoordinatorApi { get }
}
