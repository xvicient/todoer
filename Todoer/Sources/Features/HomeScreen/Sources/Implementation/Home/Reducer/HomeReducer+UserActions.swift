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
        guard let index = state.lists.firstIndex(where: \.isEditing) else {
            return .none
        }
        
        state.viewState = .loading(false)
        
        if state.lists[index].name.isEmpty {
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
            let list = state.lists[index]
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
    
    @discardableResult
    func onDidChangeSearchFocus(
        state: inout State,
        isFocused: Bool
    ) -> Effect<Action> {
        if isFocused {
            _ = onDidTapCancelButton(state: &state)
            state.editMode = .inactive
        }
        state.viewState = .idle
        return .none
    }
    
    @discardableResult
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        state.editMode = editMode
        state.viewState = .idle
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
            state.viewState = state.viewState == .editing ? .idle : .editing
            return .none
        case .all:
            return performAction(state: &state, activeTab: .all)
        case .done:
            return performAction(state: &state, activeTab: .all)
        case .todo:
            return performAction(state: &state, activeTab: .all)
        }
    }
    
    @discardableResult
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
        state.viewState = .editing
        state.activeTab = .all
        onDidUpdateSearchText(state: &state, searchText: "")
        onDidChangeSearchFocus(state: &state, isFocused: false)
        state.editMode = .inactive
        state.lists.insert(UserList.empty, at: 0)
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
        state.viewState = .idle
        state.activeTab = activeTab
        onDidChangeEditMode(state: &state, editMode: .inactive)
        return .none
    }
}
