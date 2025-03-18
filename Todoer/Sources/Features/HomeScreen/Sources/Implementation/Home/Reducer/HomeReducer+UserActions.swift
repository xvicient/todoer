import Entities
import Foundation
import xRedux
import ThemeComponents

// MARK: - Reducer user actions

extension Home.Reducer {

    @MainActor
    func onDidTapList(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
            let list = state.viewModel.lists[safe: index]?.list
        else {
            state.viewState = .error()
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
            state.viewModel.lists[safe: index] != nil
        else {
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

    func onDidTapDeleteListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
            let list = state.viewModel.lists[safe: index]?.list
        else {
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

    @MainActor
    func onDidTapShareListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
            let list = state.viewModel.lists[safe: index]?.list
        else {
            state.viewState = .error()
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
            let list = state.viewModel.lists[safe: index]?.list
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .editingList(uid)
        state.viewModel.lists.remove(at: index)
        state.viewModel.lists.insert(
            newListRow(
                list: list
            ),
            at: index
        )

        return .none
    }

    func onDidTapUpdateListButton(
        state: inout State,
        uid: UUID,
        name: String
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
            var list = state.viewModel.lists[safe: index]?.list
        else {
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

    func onDidTapCancelEditListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.index(for: uid),
            let list = state.viewModel.lists[safe: index]?.list
        else {
            state.viewState = .error()
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
    
    /// Handles the reordering of lists when a user performs a drag and drop operation.
    /// This function manages both the UI state and the persistence of the new order.
    ///
    /// The function works with both all lists and sharing lists views by:
    /// 1. Mapping the source indices from the filtered view to the main list
    /// 2. Performing the move operation on the main list
    /// 3. Reindexing all items to maintain proper order
    /// 4. Persisting the changes through the use case
    ///
    /// - Parameters:
    ///   - state: The current state to be modified
    ///   - fromIndex: The indices of items being moved in the filtered view
    ///   - toIndex: The destination index in the filtered view
    ///   - source: The source view (.allLists or .sharingLists) where the reordering occurred
    /// - Returns: An effect that persists the new order through the use case
    func onDidSortLists(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int,
        source: TDListTab
    ) -> Effect<Action> {
        state.viewState = .sortingList
        let sortedLists = state.viewModel.lists.filter(by: source.isCompleted)
        
        // 1. Map the indices from filtered list to main list
        let mainListFromIndex = IndexSet(fromIndex.map { sourceIndex in
            state.viewModel.lists.firstIndex { $0.id == sortedLists[sourceIndex].id } ?? 0
        })
        
        // 2. When moving to the end, toIndex will be equal to the array count
        let mainListToIndex: Int
        if toIndex >= sortedLists.count {
            mainListToIndex = state.viewModel.lists.count
        } else {
            mainListToIndex = state.viewModel.lists.firstIndex { $0.id == sortedLists[toIndex].id } ?? 0
        }
        
        // 3. Move items in the main list
        state.viewModel.lists.move(fromOffsets: mainListFromIndex, toOffset: mainListToIndex)
        state.viewModel.lists.reIndex()
        
        // 4. Persisting the changes through the use case
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
        state.viewModel.lists.sorted()
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
    fileprivate func newListRow(
        list: UserList = UserList.empty
    ) -> WrappedUserList {
        WrappedUserList(
            id: list.id,
            list: list,
            isEditing: true
        )
    }
}
