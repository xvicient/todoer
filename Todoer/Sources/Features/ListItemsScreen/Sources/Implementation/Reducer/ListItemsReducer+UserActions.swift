import Entities
import Foundation
import xRedux
import ThemeComponents
import SwiftUI

// MARK: - Reducer user actions

extension ListItems.Reducer {
    
    func onDidUpdateSearchText(
        state: inout State,
        searchText: String
    ) -> Effect<Action> {
        state.searchText = searchText
        return .none
    }

    func onDidTapToggleItemButton(
        state: inout State,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              state.items[safe: index] != nil
        else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .loading(false)
        
        state.items[index].done.toggle()
        
        let item = state.items[index]
        var list = dependencies.list
        list.done = state.items.allSatisfy { $0.done }
        
        return .task { send in
            await send(
                .voidResult(
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
        guard let index = state.items.index(for: uid) else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .loading(false)
        
        let itemId = state.items[index].documentId
        state.items.remove(at: index)
        
        return .task { send in
            await send(
                .voidResult(
                    dependencies.useCase.deleteItem(
                        itemId: itemId,
                        listId: dependencies.list.documentId
                    )
                )
            )
        }
    }
    
    @discardableResult
    func onDidTapCancelButton(
        state: inout State
    ) -> Effect<Action> {
        guard state.items.contains(where: \.isEditing) else {
            return .none
        }
        
        state.viewState = .idle
        state.items.removeAll { $0.isEditing }
        return .none
    }

    func onDidTapSubmitItemButton(
        state: inout State,
        newItemName: String,
        uid: UUID
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid) else {
            return .none
        }
        
        var list = dependencies.list
        let item = state.items[index]
        
        if item.name.isEmpty {
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
        } else {
            return .task { send in
                await send(
                    .updateItemResult(
                        dependencies.useCase.updateItemName(
                            item: item,
                            listId: list.documentId
                        )
                    )
                )
            }
        }
    }
    
    func onDidMoveItem(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        
        state.items.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: state.activeTab.isCompleted
        )
        
        let items = state.items
        let listId = dependencies.list.documentId
        
        return .task { send in
            await send(
                .voidResult(
                    dependencies.useCase.sortItems(
                        items: items,
                        listId: listId
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
            return addItem(state: &state)
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

}

fileprivate extension ListItems.Reducer {
    func addItem(
        state: inout State
    ) -> Effect<Action> {
        guard !state.items.contains(where: \.isEditing) else {
            return .none
        }

        state.activeTab = .all
        state.isSearchFocused = false
        state.items.insert(Item.empty, at: 0)
        state.viewState = .updating
        
        return .none
    }
    
    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.items.sorted()
        
        let items = state.items
        let listId = dependencies.list.documentId
        
        return .task { send in
            await send(
                .voidResult(
                    dependencies.useCase.sortItems(
                        items: items,
                        listId: listId
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

// MARK: - Empty item

extension Item {
    fileprivate static var empty: Item {
        Item(
            id: UUID(),
            documentId: "",
            name: "",
            done: false,
            index: -Date().milliseconds
        )
    }
}

private extension EditMode {
    var viewState: ListItems.Reducer.ViewState {
        switch self {
        case .active:
            .updating
        default:
            .idle
        }
    }
}
