import Application
import Foundation
import Entities

/// Extension handling user-initiated actions in the ListItems reducer
extension ListItems.Reducer {
    /// Handles tapping the add row button
    /// - Parameter state: Current state to update
    /// - Returns: Effect to execute
    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard
            !state.viewModel.items.contains(
                where: { $0.isEditing }
            )
        else {
            return .none
        }
        state.viewState = .addingItem
        state.viewModel.items.insert(newItemRow(), at: 0)
        return .none
    }

    /// Handles tapping the submit item button
    /// - Parameters:
    ///   - state: Current state to update
    ///   - name: Name of the item to add
    /// - Returns: Effect to execute
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

    /// Handles tapping the cancel add row button
    /// - Parameter state: Current state to update
    /// - Returns: Effect to execute
    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.items.removeAll { $0.isEditing }
        return .none
    }

    /// Handles tapping the delete item button
    /// - Parameters:
    ///   - state: Current state to update
    ///   - itemId: ID of the item to delete
    /// - Returns: Effect to execute
    func onDidTapDeleteItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.items.index(for: uid) else {
            state.viewState = .error(Errors.default)
            return .none
        }
        let itemId = state.viewModel.items[index].item.documentId
        state.viewState = .updatingItem
        state.viewModel.items.remove(at: index)
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

    /// Handles tapping the toggle item button
    /// - Parameters:
    ///   - state: Current state to update
    ///   - item: Item to toggle
    /// - Returns: Effect to execute
    func onDidTapToggleItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.items.index(for: uid),
              state.viewModel.items[safe: index] != nil else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .updatingItem
        state.viewModel.items[index].item.done.toggle()
        let item = state.viewModel.items[index].item
        var list = dependencies.list
        list.done = state.viewModel.items.allSatisfy({ $0.item.done })
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

    /// Handles tapping the edit item button
    /// - Parameters:
    ///   - state: Current state to update
    ///   - item: Item to edit
    /// - Returns: Effect to execute
    func onDidTapEditItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.items.index(for: uid),
              let item = state.viewModel.items[safe: index]?.item else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .editingItem
        state.viewModel.items.remove(at: index)
        state.viewModel.items.insert(newItemRow(item: item), at: index)

        return .none
    }

    /// Handles tapping the sort items button
    /// - Parameter state: Current state to update
    /// - Returns: Effect to execute
    func onDidTapAutoSortItems(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .sortingItems
        state.viewModel.items
            .filter { !$0.item.done }
            .enumerated()
            .forEach { index, item in
                if let fromOffset = state.viewModel.items.firstIndex(where: { $0.id == item.id }) {
                    state.viewModel.items.move(
                        fromOffsets: IndexSet(integer: fromOffset),
                        toOffset: index
                    )
                }
            }
        let items = state.viewModel.items
            .map { $0.item }
        let listId = dependencies.list.documentId
        return .task { send in
            await send(
                .sortItemsResult(
                    dependencies.useCase.sortItems(
                        items: items,
                        listId: listId
                    )
                )
            )
        }
    }

    /// Handles tapping the dismiss error button
    /// - Parameter state: Current state to update
    /// - Returns: Effect to execute
    func onDidTapDismissErrorButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }

    /// Creates a new item row with default values
    /// - Parameter item: Optional item to base the row on, defaults to an empty item
    /// - Returns: A wrapped item ready for display
    fileprivate func newItemRow(
        item: Item = Item.emptyItem
    ) -> WrappedItem {
        WrappedItem(
            id: item.id,
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
