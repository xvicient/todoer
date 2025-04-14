import Entities
import Foundation
import xRedux
import ThemeComponents
import SwiftUI
import Common
import Combine

// MARK: - Reduce

extension ListItemsReducer {
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch (state.viewState, action) {
        case (.idle, .onAppear):
            return onAppear(
                state: &state
            )
            
        case (.updating, .didTapSubmitItemButton(let uid, let newItemName)),
            (.adding, .didTapSubmitItemButton(let uid, let newItemName)):
            return onDidTapSubmitItemButton(
                state: &state,
                newItemName: newItemName,
                uid: uid
            )
            
        case (.idle, .didTapToggleItemButton(let rowId)):
            return onDidTapToggleItemButton(
                state: &state,
                uid: rowId
            )

        case (.idle, .didTapDeleteItemButton(let rowId)):
            return onDidTapDeleteItemButton(
                state: &state,
                uid: rowId
            )
            
        case (.updating, .didMoveItem(let fromIndex, let toIndex)):
            return onDidMoveItem(
                state: &state,
                fromIndex: fromIndex,
                toIndex: toIndex
            )
            
        case (_, .didChangeSearchFocus(let isFocused)):
            return onDidChangeSearchFocus(
                state: &state,
                isFocused: isFocused
            )
            
        case (.idle, .didChangeEditMode(let editMode)),
            (.adding, .didChangeEditMode(let editMode)),
            (.updating, .didChangeEditMode(let editMode)):
            return onDidChangeEditMode(
                state: &state,
                editMode: editMode
            )
            
        case (.idle, .didChangeActiveTab(let activeTab)),
            (.adding, .didChangeActiveTab(let activeTab)),
            (.updating, .didChangeActiveTab(let activeTab)):
            return onDidChangeActiveTab(
                state: &state,
                activeTab: activeTab
            )
            
        case (.idle, .didUpdateSearchText(let text)):
            state.searchText = text
            return .none

        case (_, .fetchItemsResult(let result)):
            return onFetchItemsResult(
                state: &state,
                result: result
            )

        case (.adding, .addItemResult(let result)):
            return onAddItemResult(
                state: &state,
                result: result
            )
            
        case (.updating, .updateItemResult(let result)):
            return onUpdateItemResult(
                state: &state,
                result: result
            )
            
        case (.loading, .voidResult(let result)),
            (.idle, .voidResult(let result)):
            return onVoidResult(
                state: &state,
                result: result
            )
            
        case (.updating, .moveItemResult(.failure)):
            state.viewState = .error()
            return.none

        case (.alert, .didTapDismissError):
            state.viewState = .idle
            return .none

        default:
            Logger.log(
                "No matching ViewState: \(state.viewState.rawValue) and Action: \(action.rawValue)"
            )
            return .none
        }
    }
}

// MARK: - Actions

fileprivate extension ListItemsReducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(true)
        return .publish(
            dependencies.useCase.fetchItems(
                listId: dependencies.list.id
            )
            .map { .fetchItemsResult(.success($0)) }
            .catch { Just(.fetchItemsResult(.failure($0))) }
            .eraseToAnyPublisher()
        )
    }
    
    func onDidTapToggleItemButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              state.items[safe: index] != nil else {
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
        uid: String
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              let item = state.items[safe: index] else {
            state.viewState = .error(Errors.default)
            return .none
        }
        state.viewState = .loading(false)
        state.items.remove(at: index)
        
        return .task { send in
            await send(
                .voidResult(
                    dependencies.useCase.deleteItem(
                        itemId: item.id,
                        listId: dependencies.list.id
                    )
                )
            )
        }
    }

    func onDidTapSubmitItemButton(
        state: inout State,
        newItemName: String,
        uid: String?
    ) -> Effect<Action> {
        var list = dependencies.list
        
        if let uid {
            guard let index = state.items.index(for: uid) else {
                return .none
            }
            var item = state.items[index]
            item.name = newItemName
            
            return .task { send in
                await send(
                    .updateItemResult(
                        dependencies.useCase.updateItemName(
                            item: item,
                            listId: list.id
                        )
                    )
                )
            }
        } else {
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
        }
    }
    
    func onDidMoveItem(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        let items = state.items.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            activeTab: state.activeTab
        )
        
        let listId = dependencies.list.id
        
        return .task { send in
            await send(
                .moveItemResult(
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
        state.isSearchFocused = isFocused
        
        if isFocused {
            didFinishAdding(state: &state)
            
            if state.editMode.isEditing {
                state.editMode = .inactive
                state.viewState = state.editMode.viewState
            }
        }
        
        return .none
    }
    
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        if !state.editMode.isEditing && state.viewState == .adding {
            didFinishAdding(state: &state)
        }
        state.isSearchFocused = false
        state.editMode = editMode
        state.viewState = editMode.viewState
        return .none
    }
    
    func onDidChangeActiveTab(
        state: inout State,
        activeTab: TDListTabItem
    ) -> Effect<Action> {
        
        /// Canceling edit mode if active if the user wants to add an item
        if state.editMode == .active { state.editMode = .inactive }
        
        switch activeTab {
        case .add:
            return addItem(state: &state)
        case .sort:
            return sortLists(state: &state)
        case .edit:
            /// Handled in onDidChangeEditMode since we're using a EditButton
            return .none
        case .all:
            return performAction(state: &state, activeTab: .all)
        case .done:
            return performAction(state: &state, activeTab: .done)
        case .todo:
            return performAction(state: &state, activeTab: .todo)
        }
    }
    
    func didFinishAdding(
        state: inout State
    ) {
        state.viewState = .idle
        state.activeTab = .add(false)
        state.isSearchFocused = false
    }
    
    func addItem(
        state: inout State
    ) -> Effect<Action> {
        switch state.viewState {
        case .idle:
            state.viewState = .adding
            state.activeTab = .add(true)
            state.isSearchFocused = false
            return .none
        case .adding:
            didFinishAdding(state: &state)
            return .none
        default:
            return .none
        }
    }
    
    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.items.sorted()
        
        let items = state.items
        let listId = dependencies.list.id
        
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
        activeTab: TDListTabItem
    ) -> Effect<Action> {
        guard state.activeTab != activeTab else { return .none }
        state.activeTab = activeTab
        state.viewState = .idle
        return .none
    }
}

// MARK: - Results

extension ListItemsReducer {
    func onFetchItemsResult(
        state: inout State,
        result: ActionResult<[Item]>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            if case .loading = state.viewState { state.viewState = .idle }
            state.items = items
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onAddItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        didFinishAdding(state: &state)
        switch result {
        case .success(let item):
            state.items.insert(item, at: 0)
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onUpdateItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            guard let index = state.items.firstIndex(where: { $0.id == item.id }) else {
                state.viewState = .error()
                return .none
            }
            state.items.replace(item, at: index)
            state.viewState = .updating
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    
    func onVoidResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }
}

// MARK: - Extensions

extension EditMode {
    var viewState: ListItemsReducer.ViewState {
        switch self {
        case .active:
            .updating
        default:
            .idle
        }
    }
}
