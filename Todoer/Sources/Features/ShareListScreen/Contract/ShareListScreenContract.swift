import CoordinatorContract
import Entities

/// Contract defining dependencies and data types for the ShareList feature
public protocol ShareListScreenDependencies {
    /// List to be shared
    var list: UserList { get }
    /// Coordinator for handling navigation
    var coordinator: CoordinatorApi { get }

}
