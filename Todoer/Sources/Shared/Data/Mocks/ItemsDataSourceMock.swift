/// Mock implementation of ItemsDataSourceApi for testing purposes
public class ItemsDataSourceMock: ItemsDataSourceApi {
    /// Result to return for fetchItems operations
    public var fetchItemsResult: [ItemDTO]!
    /// Result to return for addItem operations
    public var addItemResult: Result<ItemDTO, Error>!
    /// Result to return for deleteItem operations
    public var deleteItemResult: Result<Void, Error>!
    /// Result to return for updateItem operations
    public var updateItemResult: Result<ItemDTO, Error>!
    /// Result to return for toggleAllItems operations
    public var toogleAllItemsResult: Result<Void, Error>!
    /// Result to return for sortItems operations
    public var sortItemsResult: ActionResult<EquatableVoid>!
    
    public init() {}
    
    /// Mock error type for testing failure scenarios
    public enum DataSourceError: Error {
        case error
    }
    
    /// Mock implementation of documents query
    /// - Parameter listId: ID of the list to query
    /// - Returns: Empty array of QueryDocumentSnapshot
    public func documents(listId: String) async throws -> [QueryDocumentSnapshot] {
        [QueryDocumentSnapshot]()
    }
    
    /// Mock implementation of fetchItems
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: Publisher emitting a single mock item
    public func fetchItems(listId: String) -> AnyPublisher<[ItemDTO], any Error> {
        Just([
            ItemDTO(
                id: "",
                name: "",
                done: false,
                index: 1
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    /// Mock implementation of addItem
    /// - Parameters:
    ///   - name: Name of the item to add
    ///   - listId: ID of the list to add to
    /// - Returns: The configured mock result
    /// - Throws: The configured error if result is failure
    public func addItem(with name: String, listId: String) async throws -> ItemDTO {
        switch addItemResult {
        case .success(let item):
            return item
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing addItemResult mock")
            throw DataSourceError.error
        }
    }
    
    /// Mock implementation of deleteItem
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Throws: The configured error if result is failure
    public func deleteItem(itemId: String, listId: String) async throws {
        switch deleteItemResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing deleteItemResult mock")
            throw DataSourceError.error
        }
    }
    
    /// Mock implementation of updateItem
    /// - Parameters:
    ///   - item: Item to update
    ///   - listId: ID of the list containing the item
    /// - Returns: The configured mock result
    /// - Throws: The configured error if result is failure
    public func updateItem(item: ItemDTO, listId: String) async throws -> ItemDTO {
        switch updateItemResult {
        case .success(let item):
            return item
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing updateItemResult mock")
            throw DataSourceError.error
        }
    }
    
    /// Mock implementation of toggleAllItems
    /// - Parameters:
    ///   - listId: ID of the list containing the items
    ///   - done: New completion status
    /// - Throws: The configured error if result is failure
    public func toogleAllItems(listId: String, done: Bool) async throws {
        switch toogleAllItemsResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing toogleAllItemsResult mock")
            throw DataSourceError.error
        }
    }
    
    /// Mock implementation of sortItems
    /// - Parameters:
    ///   - items: Items to sort
    ///   - listId: ID of the list containing the items
    /// - Throws: The configured error if result is failure
    public func sortItems(items: [ItemDTO], listId: String) async throws {
        switch sortItemsResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing sortItemsResult mock")
            throw DataSourceError.error
        }
    }
}
