/// Mock implementation of ListItemsUseCaseApi for testing purposes
class ListItemsUseCaseMock: ListItemsUseCaseApi {
    
    /// Result to return for fetchItems operations
    var fetchItemsResult: ActionResult<[Item]>!
    /// Result to return for addItem operations
    var addItemResult: ActionResult<Item>!
    /// Result to return for deleteItem operations
    var deleteItemResult: ActionResult<EquatableVoid>!
    /// Result to return for updateItemName operations
    var updateItemNameResult: ActionResult<Item>!
    /// Result to return for updateItemDone operations
    var updateItemDoneResult: ActionResult<Item>!
    /// Result to return for sortItems operations
    var sortItemsResult: ActionResult<EquatableVoid>!
    
    /// Mock error type for testing failure scenarios
    enum UseCaseError: Error {
        case error
    }
    
    /// Mock implementation of fetchItems
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: Publisher emitting items based on the configured result
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], any Error> {
        switch fetchItemsResult {
        case .success(let items):
            return Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure:
            return Fail<[Item], Error>(
                error: UseCaseError.error
            )
            .eraseToAnyPublisher()
        case .none:
            assertionFailure("Missing fetchItemsResult mock")
            return Empty<[Item], Error>(completeImmediately: false)
                .eraseToAnyPublisher()
        }
    }
    
    /// Mock implementation of addItem
    /// - Parameters:
    ///   - name: Name of the item to add
    ///   - list: List to add the item to
    /// - Returns: The configured mock result
    func addItem(
        with name: String,
        list: UserList
    ) async -> ActionResult<Item> {
        addItemResult
    }
    
    /// Mock implementation of deleteItem
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Returns: The configured mock result
    func deleteItem(
        itemId: String,
        listId: String
    ) async -> ActionResult<EquatableVoid> {
        deleteItemResult
    }
    
    /// Mock implementation of updateItemName
    /// - Parameters:
    ///   - item: Item to update
    ///   - listId: ID of the list containing the item
    /// - Returns: The configured mock result
    func updateItemName(
        item: Item,
        listId: String
    ) async -> ActionResult<Item> {
        updateItemNameResult
    }
    
    /// Mock implementation of updateItemDone
    /// - Parameters:
    ///   - item: Item to update
    ///   - list: List containing the item
    /// - Returns: The configured mock result
    func updateItemDone(
        item: Item,
        list: UserList
    ) async -> ActionResult<Item> {
        updateItemDoneResult
    }
    
    /// Mock implementation of sortItems
    /// - Parameters:
    ///   - items: Items to sort
    ///   - listId: ID of the list containing the items
    /// - Returns: The configured mock result
    func sortItems(
        items: [Item],
        listId: String
    ) async -> ActionResult<EquatableVoid> {
        sortItemsResult
    }
}
