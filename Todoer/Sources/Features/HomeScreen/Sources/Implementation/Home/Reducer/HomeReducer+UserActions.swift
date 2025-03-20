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
        state.editMode = .inactive
        dependencies.coordinator.push(.listItems(list))
        return .none
    }

    @discardableResult
    func onDidTapCancelButton(
        state: inout State
    ) -> Effect<Action> {
        guard let index = state.lists.firstIndex(where: \.isEditing) else {
            return .none
        }
        
        if state.lists[index].name.isEmpty {
            state.lists.removeAll { $0.isEditing }
        } else {
            state.lists.replace(
                state.lists[index],
                at: index
            )
        }
        
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
                .homeResult(
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
                .homeResult(
                    useCase.deleteList(list.documentId)
                )
            )
        }
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String
    ) -> Effect<Action> {
        guard var list = state.lists.last else {
            return .none
        }
        
        state.viewState = .loading(false)
        
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
        state.viewState = .loading(false)
        
        state.lists.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: state.activeTab.isCompleted
        )
        
        let lists = state.lists
        
        return .task { send in
            await send(
                .homeResult(
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
            state.editMode = .inactive
        }
        return .none
    }
    
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        state.editMode = editMode
        state.viewState = editMode.isEditing ? .editing : .idle
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
        state.editMode = .inactive
        state.lists.insert(UserList.empty, at: 0)
        state.viewState = .editing
        
        return .none
    }
    
    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.editMode = .inactive
        state.lists.sorted()
        
        let lists = state.lists
        
        return .task { send in
            await send(
                .homeResult(
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
        state.editMode = .inactive
        state.viewState = .idle
        return .none
    }
}
