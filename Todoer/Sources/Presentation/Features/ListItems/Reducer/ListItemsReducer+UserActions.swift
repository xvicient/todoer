import Foundation
import Data

// MARK: - Reducer user actions

@MainActor
extension ListItems.Reducer {
	func onDidTapToggleItemButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard state.viewModel.items[safe: index] != nil else {
			state.viewState = .error(Errors.default)
			return .none
		}
		state.viewState = .updatingItem
		state.viewModel.items[index].item.done.toggle()
		let item = state.viewModel.items[index].item
		var list = dependencies.list
		list.done = state.viewModel.items.allSatisfy({ $0.item.done })
		return .task { @MainActor send in
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
		index: Int
	) -> Effect<Action> {
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
		return .task { @MainActor send in
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
		index: Int
	) -> Effect<Action> {
		guard let item = state.viewModel.items[safe: index]?.item else {
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
		index: Int,
		name: String
	) -> Effect<Action> {
		guard var item = state.viewModel.items[safe: index]?.item else {
			state.viewState = .error(Errors.default)
			return .none
		}
		item.name = name
		let listId = dependencies.list.documentId
		return .task { @MainActor send in
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
		index: Int
	) -> Effect<Action> {
		guard let item = state.viewModel.items[safe: index]?.item else {
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

}

// MARK: - Private

extension ListItems.Reducer {
	fileprivate func newItemRow(item: Item = Item.emptyItem) -> ItemRow {
		ItemRow(
			item: item,
			isEditing: true
		)
	}
}

// MARK: - Empty item

extension Item {
	fileprivate static var emptyItem: Item {
		Item(
			documentId: "",
			name: "",
			done: false,
			index: Date().milliseconds
		)
	}
}
