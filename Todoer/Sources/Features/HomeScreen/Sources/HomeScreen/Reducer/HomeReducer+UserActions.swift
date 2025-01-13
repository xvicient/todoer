import Foundation
import Entities
import Application

// MARK: - Reducer user actions

extension Home.Reducer {
	func onDidTapAcceptInvitation(
		state: inout State,
		listId: String,
		invitationId: String
	) -> Effect<Action> {
		return .task { send in
			await send(
				.acceptInvitationResult(
					dependencies.useCase.acceptInvitation(
						listId: listId,
						invitationId: invitationId
					)
				)
			)
		}
	}

	func onDidTapDeclineInvitation(
		state: inout State,
		invitationId: String
	) -> Effect<Action> {
		return .task { send in
			await send(
				.declineInvitationResult(
					dependencies.useCase.declineInvitation(
						invitationId: invitationId
					)
				)
			)
		}
	}

    @MainActor
    func onDidTapList(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		dependencies.coordinator.push(.listItems(list))
		return .none
	}

	func onDidTapToggleListButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard state.viewModel.lists[safe: index] != nil else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .updatingList
		state.viewModel.lists[index].list.done.toggle()
		let list = state.viewModel.lists[index].list
		return .task { send in
			await send(
				.toggleListResult(
					dependencies.useCase.updateList(
						list: list
					)
				)
			)
		}
	}

	func onDidTapDeleteListButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		state.viewState = .updatingList
		state.viewModel.lists.remove(at: index)
		return .task { send in
			await send(
				.deleteListResult(
					dependencies.useCase.deleteList(list.documentId)
				)
			)
		}
	}

    @MainActor
    func onDidTapShareListButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard let list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		dependencies.coordinator.present(sheet: .shareList(list))

		return .none
	}

	func onDidTapEditListButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard let list = state.viewModel.lists[safe: index]?.list else {
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
		index: Int,
		name: String
	) -> Effect<Action> {
		guard var list = state.viewModel.lists[safe: index]?.list else {
			state.viewState = .alert(.error(Errors.default))
			return .none
		}
		list.name = name
		return .task { send in
			await send(
				.addListResult(
					dependencies.useCase.updateList(
						list: list
					)
				)
			)
		}
	}

	func onDidTapCancelEditListButton(
		state: inout State,
		index: Int
	) -> Effect<Action> {
		guard let list = state.viewModel.lists[safe: index]?.list else {
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
					dependencies.useCase.addList(
						name: newListName
					)
				)
			)
		}
	}

    @MainActor
	func onDidTapSignoutButton(
		state: inout State
	) -> Effect<Action> {
		switch dependencies.useCase.signOut() {
		case .success:
			dependencies.coordinator.loggOut()
		case .failure:
			state.viewState = .alert(.error(Errors.default))
		}
		return .none
	}

    @MainActor
    func onDidTapAboutButton(
		state: inout State
	) -> Effect<Action> {
		dependencies.coordinator.push(.about)
		return .none
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
					dependencies.useCase.sortLists(
						lists: lists
					)
				)
			)
		}
	}

	func onDidTapDeleteAccountButton(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .alert(.destructive)
		return .none
	}

	func onDidTapConfirmDeleteAccount(
		state: inout State
	) -> Effect<Action> {
		return .task { send in
			await send(
				.deleteAccountResult(
					dependencies.useCase.deleteAccount()
				)
			)
		}
	}

	func onDidTapDismissDeleteAccount(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
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
					dependencies.useCase.sortLists(
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
