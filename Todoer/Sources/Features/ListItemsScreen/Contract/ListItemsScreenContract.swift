import Entities

/// Contract defining dependencies and data types for the ListItems feature
public protocol ListItemsScreenDependencies {
    /// List containing the items
    var list: UserList { get }
}
