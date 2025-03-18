import Entities
import Foundation
import xRedux
import ThemeComponents

// MARK: - Reducer user actions

extension ListItems.Reducer {
    
    func onDidUpdateSearchText(
        state: inout State,
        searchText: String
    ) -> Effect<Action> {
        state.searchText = searchText
        return .none
    }

    func onDidTapToggleItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              state.items[safe: index] != nil
        else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .updatingItem
        state.items[index].item.done.toggle()
        let item = state.items[index].item
        var list = dependencies.list
        list.done = state.items.allSatisfy { $0.item.done }
        return .task { send in
            await send(
                .toggleItemResult(
                    dependencies.useCase.updateItemDone(
                        item: item,
                        list: list
                    )
                )
            )
        }
    }

    func onDidTapDeleteItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid) else {
            state.viewState = .error(Errors.default)
            return .none
        }
        let itemId = state.items[index].item.documentId
        state.viewState = .updatingItem
        state.items.remove(at: index)
        return .task { send in
            await send(
                .deleteItemResult(
                    dependencies.useCase.deleteItem(
                        itemId: itemId,
                        listId: dependencies.list.documentId
                    )
                )
            )
        }
    }

    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.items.contains(where: { $0.isEditing }) else {  return .none }

        state.viewState = .addingItem
        state.items.insert(newItemRow(), at: 0)
        return .none
    }

    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.items.removeAll { $0.isEditing }
        return .none
    }

    func onDidTapSubmitItemButton(
        state: inout State,
        newItemName: String
    ) -> Effect<Action> {
        var list = dependencies.list
        list.done = false
        return .task { send in
            await send(
                .addItemResult(
                    dependencies.useCase.addItem(
                        with: newItemName,
                        list: list
                    )
                )
            )
        }
    }

    func onDidTapEditItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
            let item = state.items[safe: index]?.item
        else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .editingItem(uid)
        state.items.remove(at: index)
        state.items.insert(newItemRow(item: item), at: index)

        return .none
    }

    func onDidTapUpdateItemButton(
        state: inout State,
        uid: UUID,
        name: String
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
            var item = state.items[safe: index]?.item
        else {
            state.viewState = .error(Errors.default)
            return .none
        }
        item.name = name
        let listId = dependencies.list.documentId
        return .task { send in
            await send(
                .addItemResult(
                    dependencies.useCase.updateItemName(
                        item: item,
                        listId: listId
                    )
                )
            )
        }
    }

    func onDidTapCancelEditItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
            let item = state.items[safe: index]?.item
        else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .idle
        state.items.remove(at: index)
        state.items.insert(item.toItemRow, at: index)
        return .none
    }
    
    func onDidMoveItem(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int,
        isCompleted: Bool?
    ) -> Effect<Action> {
        state.viewState = .movingItem
        
        state.items.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: isCompleted
        )
        
        let items = state.items
            .map { $0.item }
        let listId = dependencies.list.documentId
        
        return .task { send in
            await send(
                .moveItemsResult(
                    dependencies.useCase.sortItems(
                        items: items,
                        listId: listId
                    )
                )
            )
        }
    }

    func onDidTapAutoSortItems(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .sortingItems
        state.items.sorted()
        let items = state.items
            .map { $0.item }
        let listId = dependencies.list.documentId
        return .task { send in
            await send(
                .moveItemsResult(
                    dependencies.useCase.sortItems(
                        items: items,
                        listId: listId
                    )
                )
            )
        }
    }

}

// MARK: - Private

extension ListItems.Reducer {
    fileprivate func newItemRow(
        item: Item = Item.emptyItem
    ) -> WrappedItem {
        WrappedItem(
            item: item,
            isEditing: true
        )
    }
}

// MARK: - Empty item

extension Item {
    fileprivate static var emptyItem: Item {
        Item(
            id: UUID(),
            documentId: "",
            name: "",
            done: false,
            index: -Date().milliseconds
        )
    }
}
