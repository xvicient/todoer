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
        guard let index = state.lists.index(for: uid),
            let list = state.lists[safe: index]
        else {
            state.viewState = .error()
            return .none
        }
        dependencies.coordinator.push(.listItems(list))
        return .none
    }

    @discardableResult
    func onDidTapCancelButton(
        state: inout State
    ) -> Effect<Action> {
        guard state.lists.contains(where: \.isEditing) else {
            return .none
        }
        
        state.lists.removeAll { $0.isEditing }
        state.viewState = .idle
        
        return .none
    }

    func onDidTapToggleListButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
            state.lists[safe: index] != nil
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.lists[index].done.toggle()
        let list = state.lists[index]
        
        return .task { send in
            await send(
                .voidResult(
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
        guard let index = state.lists.index(for: uid),
            let list = state.lists[safe: index]
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.lists.remove(at: index)
        
        return .task { send in
            await send(
                .voidResult(
                    useCase.deleteList(list.documentId)
                )
            )
        }
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid) else {
            return .none
        }
        
        var list = state.lists[index]
        
        if list.name.isEmpty {
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
            list.name = newListName
            return .task { send in
                await send(
                    .updateListResult(
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
        guard let index = state.lists.index(for: uid),
            let list = state.lists[safe: index]
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
        toIndex: Int
    ) -> Effect<Action> {
        
        state.lists.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: state.activeTab.isCompleted
        )
        
        let lists = state.lists
        
        return .task { send in
            await send(
                .voidResult(
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
            onDidTapCancelButton(state: &state)
        }
        return .none
    }
    
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        state.editMode = editMode
        state.viewState = editMode.viewState
        return .none
    }
    
    func onDidChangeActiveTab(
        state: inout State,
        activeTab: TDListTab
    ) -> Effect<Action> {
        switch activeTab {
        case .add:
            return addList(state: &state)
        case .sort:
            return sortLists(state: &state)
        case .edit:
            return .none /// Handled in onDidChangeEditMode
        case .all:
            return performAction(state: &state, activeTab: .all)
        case .done:
            return performAction(state: &state, activeTab: .done)
        case .todo:
            return performAction(state: &state, activeTab: .todo)
        }
    }
    
    func onDidUpdateSearchText(
        state: inout State,
        searchText: String
    ) -> Effect<Action> {
        state.searchText = searchText
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

fileprivate extension Home.Reducer {
    func addList(
        state: inout State
    ) -> Effect<Action> {
        guard !state.lists.contains(where: \.isEditing) else {
            return .none
        }
        
        state.activeTab = .all
        state.isSearchFocused = false
        state.lists.insert(UserList.empty, at: 0)
        state.viewState = .updating
        
        return .none
    }
    
    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.lists.sorted()
        
        let lists = state.lists
        
        return .task { send in
            await send(
                .voidResult(
                    useCase.sortLists(
                        lists: lists
                    )
                )
            )
        }
    }
    
    func performAction(
        state: inout State,
        activeTab: TDListTab
    ) -> Effect<Action> {
        guard state.activeTab != activeTab else { return .none }
        state.activeTab = activeTab
        state.viewState = .idle
        return .none
    }
}

private extension EditMode {
    var viewState: Home.Reducer.ViewState {
        switch self {
        case .active:
            .updating
        default:
            .idle
        }
    }
}
