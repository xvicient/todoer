import Combine
import Entities
import xRedux

@testable import ListItemsScreen

class ListItemsUseCaseMock: ListItemsUseCaseApi {

    var fetchItemsResult: ActionResult<[Item]>!
    var addItemResult: ActionResult<Item>!
    var updateItemNameResult: ActionResult<Item>!
    var voidResult: ActionResult<EquatableVoid>!

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
        voidResult
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
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func sortItems(
        items: [Item],
        listId: String
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

}
