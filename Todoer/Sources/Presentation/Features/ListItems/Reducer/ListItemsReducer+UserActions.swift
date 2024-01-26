import Foundation

// MARK: - Reducer user actions

@MainActor
internal extension ListItems.Reducer {
    func onDidTapToggleItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard state.viewModel.items[safe: index] != nil else {
            state.viewState = .error(ListItems.Errors.unexpectedError.localizedDescription)
            return .none
        }
        state.viewState = .updatingItem
        state.viewModel.items[index].item.done.toggle()
        let item = state.viewModel.items[index].item
        var list = dependencies.list
        list.done = state.viewModel.items.allSatisfy({ $0.item.done })
        return .task(Task {
            .toggleItemResult(
                await dependencies.useCase.updateItemDone(
                    item: item,
                    list: list
                )
            )
        })
    }
    
    func onDidTapDeleteItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        let itemId = state.viewModel.items[index].item.documentId
        state.viewState = .updatingItem
        state.viewModel.items.remove(at: index)
        return .task(Task {
            .deleteItemResult(
                await dependencies.useCase.deleteItem(
                    itemId: itemId,
                    listId: dependencies.list.documentId
                )
            )
        })
    }
    
    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.viewModel.items.contains(
            where: { $0.isEditing }
        ) else {
            return .none
        }
        state.viewState = .addingItem
        state.viewModel.items.append(newItemRow())
        return .none
    }
    
    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.items.removeAll { $0.isEditing }
        return .none
    }
    
    func onDidTapSubmitItemButton(
        state: inout State,
        newItemName: String
    ) -> Effect<Action> {
        var list = dependencies.list
        list.done = false
        return .task(Task {
            .addItemResult(
                await dependencies.useCase.addItem(
                    with: newItemName,
                    list: list
                )
            )
        })
    }
    
    func onDidTapEditItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        guard let item = state.viewModel.items[safe: index]?.item else {
            state.viewState = .error(ListItems.Errors.unexpectedError.localizedDescription)
            return .none
        }
        state.viewState = .editingItem
        state.viewModel.items.remove(at: index)
        state.viewModel.items.insert(newItemRow(item: item), at: index)

        return .none
    }
    
    func onDidTapUpdateItemButton(
        state: inout State,
        index: Int,
        name: String
    ) -> Effect<Action> {
        guard var item = state.viewModel.items[safe: index]?.item else {
            state.viewState = .error(ListItems.Errors.unexpectedError.localizedDescription)
            return .none
        }
        item.name = name
        let listId = dependencies.list.documentId
        return .task(Task {
            .addItemResult(
                await dependencies.useCase.updateItemName(
                    item: item,
                    listId: listId
                )
            )
        })
    }
    
    func onDidTapCancelEditItemButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.items.removeAll { $0.isEditing }
        return onAppear(state: &state)
    }
    
    func onDidSortItems(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        state.viewState = .sortingItems
        state.viewModel.items.move(fromOffsets: fromIndex, toOffset: toIndex)
        let items = state.viewModel.items
            .map { $0.item }
        let listId = dependencies.list.documentId
        return .task(Task {
            .sortItemsResult(
                await dependencies.useCase.sortItems(
                    items: items,
                    listId: listId
                )
            )
        })
    }
      
}

// MARK: - Private

private extension ListItems.Reducer {
    func newItemRow(item: Item = Item.emptyItem) -> ItemRow {
        ItemRow(
            item: item,
            isEditing: true
        )
    }
}

// MARK: - Empty item

private extension Item {
    static var emptyItem: Item {
        Item(
            documentId: "",
            name: "",
            done: false,
            index: Date().milliseconds
        )
    }
}
