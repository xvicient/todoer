import Entities
import Foundation
import xRedux
import ThemeComponents
import SwiftUI

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
        state.viewModel.editMode = .inactive
        dependencies.coordinator.push(.listItems(list))
        return .none
    }
    
    func onDidTapAddListButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.viewModel.lists.contains(where: \.isEditing) else {
            return .none
        }
        state.viewModel.editMode = .inactive
        state.viewState = .updating
        state.viewModel.lists.insert(newListRow(), at: 0)
        return .none
    }

    func onDidTapCancelButton(
        state: inout State
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.firstIndex(where: \.isEditing) else {
            return .none
        }
        
        if state.viewModel.lists[index].name.isEmpty {
            state.viewModel.lists.removeAll { $0.isEditing }
        } else {
            state.viewModel.lists.replace(
                list: state.viewModel.lists[index].list,
                at: index
            )
        }
        
        state.viewState = .idle
        
        return .none
    }
    
    func onDidTapEditButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = state.viewState == .updating ? .idle : .updating
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
        state.viewState = .loading(false)
        state.viewModel.lists[index].list.done.toggle()
        let list = state.viewModel.lists[index].list
        
        return .task { send in
            await send(
                .toggleListResult(
                    useCase.toggleList(
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
        state.viewState = .loading(false)
        state.viewModel.lists.remove(at: index)
        
        return .task { send in
            await send(
                .deleteListResult(
                    useCase.deleteList(list.documentId)
                )
            )
        }
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.firstIndex(where: \.isEditing) else {
            return .none
        }
        
        state.viewState = .loading(false)
        
        if state.viewModel.lists[index].name.isEmpty {
            return .task { send in
                await send(
                    .addListResult(
                        useCase.addList(
                            name: newListName
                        )
                    )
                )
            }
        } else {
            let list = state.viewModel.lists[index].list
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
    
    func onDidMoveList(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int,
        isCompleted: Bool?
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        
        state.viewModel.lists.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: isCompleted
        )
        
        let lists = state.viewModel.lists
            .map { $0.list }
        
        return .task { send in
            await send(
                .moveListsResult(
                    useCase.sortLists(
                        lists: lists
                    )
                )
            )
        }
    }

    func onDidTapAutoSortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.viewModel.editMode = .inactive
        state.viewModel.lists.sorted()
        let lists = state.viewModel.lists
            .map { $0.list }
        return .task { send in
            await send(
                .moveListsResult(
                    useCase.sortLists(
                        lists: lists
                    )
                )
            )
        }
    }
    
    func onDidChangeSearchFocus(
        state: inout State,
        isFocused: Bool
    ) -> Effect<Action> {
        if isFocused {
            _ = onDidTapCancelButton(state: &state)
            state.viewModel.editMode = .inactive
        }
        state.viewState = .idle
        return .none
    }
    
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        state.viewModel.editMode = editMode
        state.viewState = .idle
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
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
