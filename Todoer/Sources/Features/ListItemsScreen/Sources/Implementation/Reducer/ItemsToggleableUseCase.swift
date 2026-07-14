import Entities
import ThemeComponents
import xRedux

/// Adapts the item-level `ListItemsUseCaseApi` to the generic `TDListUseCaseApi` consumed by
/// `TDListReducer`. It carries the parent list so item operations can update the list (e.g.
/// marking the list done when every item is completed).
struct ItemsToggleableUseCase: TDListUseCaseApi {
    typealias Element = Item

    let useCase: ListItemsUseCaseApi
    let list: UserList

    func add(name: String) async -> ActionResult<Item> {
        var list = list
        list.done = false
        return await useCase.addItem(with: name, list: list)
    }

    func update(_ element: Item) async -> ActionResult<Item> {
        await useCase.updateItemName(item: element, listId: list.id)
    }

    func toggle(_ element: Item, in elements: [Item]) async -> ActionResult<EquatableVoid> {
        var list = list
        list.done = elements.allSatisfy { $0.done }
        return await useCase.updateItemDone(item: element, list: list)
    }

    func delete(_ element: Item) async -> ActionResult<EquatableVoid> {
        await useCase.deleteItem(itemId: element.id, listId: list.id)
    }

    func sort(_ elements: [Item]) async -> ActionResult<EquatableVoid> {
        await useCase.sortItems(items: elements, listId: list.id)
    }
}
