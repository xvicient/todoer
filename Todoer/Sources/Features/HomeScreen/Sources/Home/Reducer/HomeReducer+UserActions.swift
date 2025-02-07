import Foundation
import Entities
import Application

// MARK: - Reducer user actions

/// Extension containing user action handling methods for the Home Reducer
extension Home.Reducer {

    /// Handles tapping on a list item to navigate to its details
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the tapped list
    /// - Returns: Effect to execute
    @MainActor
    func onDidTapList(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
            return .none
        }
        dependencies.coordinator.push(.listItems(list))
        return .none
    }

    /// Handles toggling a list's completion status
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list to toggle
    /// - Returns: Effect to execute
    func onDidTapToggleListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              state.viewModel.lists[safe: index] != nil else {
            state.viewState = .error()
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

    /// Handles deleting a list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list to delete
    /// - Returns: Effect to execute
    func onDidTapDeleteListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
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

    /// Handles sharing a list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list to share
    /// - Returns: Effect to execute
    @MainActor
    func onDidTapShareListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
            return .none
        }
        dependencies.coordinator.present(sheet: .shareList(list))
        return .none
    }

    /// Handles entering edit mode for a list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list to edit
    /// - Returns: Effect to execute
    func onDidTapEditListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .editingList
        state.viewModel.lists.remove(at: index)
        state.viewModel.lists.insert(newListRow(
            list: list
        ), at: index)
        return .none
    }

    /// Handles updating a list's name
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list to update
    ///   - name: New name for the list
    /// - Returns: Effect to execute
    func onDidTapUpdateListButton(
        state: inout State,
        uid: UUID,
        name: String
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              var list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
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

    /// Handles cancelling list editing
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - uid: ID of the list being edited
    /// - Returns: Effect to execute
    func onDidTapCancelEditListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
              let list = state.viewModel.lists[safe: index]?.list else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .idle
        state.viewModel.lists.remove(at: index)
        state.viewModel.lists.insert(list.toListRow, at: index)
        return .none
    }

    /// Handles adding a new list row
    /// - Parameter state: Current state to modify
    /// - Returns: Effect to execute
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

    /// Handles cancelling list addition
    /// - Parameter state: Current state to modify
    /// - Returns: Effect to execute
    func onDidTapCancelAddListButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.lists.removeAll { $0.isEditing }
        return .none
    }

    /// Handles submitting a new list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - newListName: Name for the new list
    /// - Returns: Effect to execute
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

    /// Handles manual sorting of lists
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - fromIndex: Source indices of lists to move
    ///   - toIndex: Target index to move lists to
    /// - Returns: Effect to execute
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

    /// Handles dismissing an error alert
    /// - Parameter state: Current state to modify
    /// - Returns: Effect to execute
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }

    /// Handles automatic sorting of lists
    /// - Parameter state: Current state to modify
    /// - Returns: Effect to execute
    func onDidTapAutoSortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .sortingList
        let lists = state.viewModel.lists
            .sorted { !$0.list.done && $1.list.done }
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
    /// Creates a new list row for editing
    /// - Parameter list: Optional existing list to edit
    /// - Returns: Wrapped user list configured for editing
    private func newListRow(
        list: UserList? = nil
    ) -> WrappedUserList {
        WrappedUserList(
            id: list.id,
            list: list,
            isEditing: true
        )
    }
}

// MARK: - Empty list

extension UserList {
    fileprivate static var emptyList: UserList {
        UserList(
            id: UUID(),
            documentId: "",
            name: "",
            done: false,
            uid: [],
            index: -Date().milliseconds
        )
    }
}
