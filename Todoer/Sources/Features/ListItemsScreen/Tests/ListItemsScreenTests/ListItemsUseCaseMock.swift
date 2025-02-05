import xRedux
import Entities
import Combine

@testable import ListItemsScreen

class ListItemsUseCaseMock: ListItemsUseCaseApi {
    
    var fetchItemsResult: ActionResult<[Item]>!
    var addItemResult: ActionResult<Item>!
    var deleteItemResult: ActionResult<EquatableVoid>!
    var updateItemNameResult: ActionResult<Item>!
    var updateItemDoneResult: ActionResult<Item>!
    var sortItemsResult: ActionResult<EquatableVoid>!
    
    enum UseCaseError: Error {
        case error
    }
    
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
    
    func addItem(
        with name: String,
        list: UserList
    ) async -> ActionResult<Item> {
        addItemResult
    }
    
    func deleteItem(
        itemId: String,
        listId: String
    ) async -> ActionResult<EquatableVoid> {
        deleteItemResult
    }
    
    func updateItemName(
        item: Item,
        listId: String
    ) async -> ActionResult<Item> {
        updateItemNameResult
    }
    
    func updateItemDone(
        item: Item,
        list: UserList
    ) async -> ActionResult<Item> {
        updateItemDoneResult
    }
    
    func sortItems(
        items: [Item],
        listId: String
    ) async -> ActionResult<EquatableVoid> {
        sortItemsResult
    }
    
    
}
