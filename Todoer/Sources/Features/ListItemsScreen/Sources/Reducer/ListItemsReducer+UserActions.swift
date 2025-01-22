import Foundation
import Entities
import Application

// MARK: - Reducer user actions

extension ListItems.Reducer {
    
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

	func onDidTapUpdateItemButton(
		state: inout State,
        uid: UUID,
		name: String
	) -> Effect<Action> {
		guard let index = state.viewModel.items.index(for: uid),
              var item = state.viewModel.items[safe: index]?.item else {
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
		guard let index = state.viewModel.items.index(for: uid),
              let item = state.viewModel.items[safe: index]?.item else {
			state.viewState = .error(Errors.default)
			return .none
		}
		state.viewState = .idle
		state.viewModel.items.remove(at: index)
		state.viewModel.items.insert(item.toItemRow, at: index)
		return .none
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

	func onDidTapAutoSortItems(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .sortingItems
        state.viewModel.items.sort {
            if $0.item.done != $1.item.done {
                return !$0.item.done && $1.item.done
            } else {
                return $0.item.name.localizedCompare($1.item.name) == .orderedAscending
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

}

// MARK: - Private

extension ListItems.Reducer {
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
