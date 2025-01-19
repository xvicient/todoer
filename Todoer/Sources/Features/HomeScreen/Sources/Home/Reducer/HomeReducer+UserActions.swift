import Foundation
import Entities
import Application

// MARK: - Reducer user actions

extension Home.Reducer {

    @MainActor
    func onDidTapList(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		dependencies.coordinator.push(.listItems(list))
		return .none
	}

	func onDidTapToggleListButton(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              state.viewModel.lists[safe: index] != nil else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .updatingList
		state.viewModel.lists[index].list.done.toggle()
		let list = state.viewModel.lists[index].list
		return .task { send in
			await send(
				.toggleListResult(
					useCase.updateList(
						list: list
					)
				)
			)
		}
	}

	func onDidTapDeleteListButton(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .updatingList
		state.viewModel.lists.remove(at: index)
		return .task { send in
			await send(
				.deleteListResult(
					useCase.deleteList(list.documentId)
				)
			)
		}
	}

    @MainActor
    func onDidTapShareListButton(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		dependencies.coordinator.present(sheet: .shareList(list))

		return .none
	}

	func onDidTapEditListButton(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .editingList
		state.viewModel.lists.remove(at: index)
		state.viewModel.lists.insert(newListRow(list: list), at: index)

		return .none
	}

	func onDidTapUpdateListButton(
		state: inout State,
        uid: UUID,
		name: String
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              var list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		list.name = name
		return .task { send in
			await send(
				.addListResult(
					useCase.updateList(
						list: list
					)
				)
			)
		}
	}

	func onDidTapCancelEditListButton(
		state: inout State,
        uid: UUID
	) -> Effect<Action> {
		guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .idle
		state.viewModel.lists.remove(at: index)
		state.viewModel.lists.insert(list.toListRow, at: index)
		return .none
	}

	func onDidTapAddRowButton(
		state: inout State
	) -> Effect<Action> {
		guard
			!state.viewModel.lists.contains(
				where: { $0.isEditing }
			)
		else {
			return .none
		}
		state.viewState = .addingList
        state.viewModel.lists.insert(newListRow(), at: 0)
		return .none
	}

	func onDidTapCancelAddListButton(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		state.viewModel.lists.removeAll { $0.isEditing }
		return .none
	}

	func onDidTapSubmitListButton(
		state: inout State,
		newListName: String
	) -> Effect<Action> {
		return .task { send in
			await send(
				.addListResult(
					useCase.addList(
						name: newListName
					)
				)
			)
		}
	}

	func onDidSortLists(
		state: inout State,
		fromIndex: IndexSet,
		toIndex: Int
	) -> Effect<Action> {
		state.viewState = .sortingList
		state.viewModel.lists.move(fromOffsets: fromIndex, toOffset: toIndex)
		let lists = state.viewModel.lists
			.map { $0.list }
		return .task { send in
			await send(
				.sortListsResult(
					useCase.sortLists(
						lists: lists
					)
				)
			)
		}
	}

	func onDidTapDismissError(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
	}

	func onDidTapAutoSortLists(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .sortingList
		state.viewModel.lists
			.filter { !$0.list.done }
			.enumerated()
			.forEach { index, item in
				if let fromOffset = state.viewModel.lists.firstIndex(where: { $0.id == item.id }) {
					state.viewModel.lists.move(
						fromOffsets: IndexSet(integer: fromOffset),
						toOffset: index
					)
				}
			}
		let lists = state.viewModel.lists
			.map { $0.list }
		return .task { send in
			await send(
				.sortListsResult(
					useCase.sortLists(
						lists: lists
					)
				)
			)
		}
	}
}

// MARK: - Private

extension Home.Reducer {
	fileprivate func newListRow(list: UserList = UserList.emptyList) -> ListRow {
		ListRow(
			list: list,
			isEditing: true
		)
	}
}

// MARK: - Empty list

extension UserList {
	fileprivate static var emptyList: UserList {
		UserList(
			documentId: "",
			name: "",
			done: false,
			uid: [],
			index: Date().milliseconds
		)
	}
}
