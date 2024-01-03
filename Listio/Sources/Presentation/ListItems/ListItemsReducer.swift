import Combine
import SwiftUI
import Foundation

// MARK: - ListItemsReducer

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

final class ItemsModel: ListRowsViewModel {
    var rows: [any ListRow] = []
    var leadingActions: (any ListRow) -> [ListRowAction] {
        { [$0.done ? .undone : .done] }
    }
    var trailingActions = [ListRowAction.delete]
}

private struct EmptyRow: ListRow {
    var id = UUID()
    var documentId = ""
    var name = ""
    var done = false
    var isEditing = true
}

extension ListItems {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View flow start
            case viewWillAppear
            
            // MARK: - User actions
            case didTapAddItemButton(String)
            case didTapToggleItemButton(Int)
            case didTapDeleteItemButton(Int)
            case didTapAddRowButton
            case didTapCancelAddRowButton
            
            // MARK: - Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case updateItemResult(Result<Item, Error>)
        }
        
        @MainActor
        struct State {
            var isLoading = false
            var itemsModel = ItemsModel()
            var listName = ""
            var isAddNewItemButtonVisible = true
            var cleanNewItemName = true
        }
        
        private let dependencies: ListItemsDependencies
        
        init(dependencies: ListItemsDependencies) {
            self.dependencies = dependencies
        }
        
        @MainActor 
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            
            switch action {
            case .viewWillAppear:
                return onViewWillAppear(
                    state: &state
                )
                
            case .didTapAddItemButton(let newItemName):
                return onDidTapAddItemButton(
                    state: &state,
                    newItemName: newItemName
                )
                
            case .didTapToggleItemButton(let index):
                return onDidTapToggleItemButton(
                    state: &state,
                    index: index
                )
                
            case .didTapDeleteItemButton(let index):
                return onDidTapDeleteItemButton(
                    state: &state,
                    index: index
                )
            
            case .didTapAddRowButton:
                return onDidTapAddRowButton(
                    state: &state
                )
            
            case .didTapCancelAddRowButton:
                return onDidTapCancelAddRowButton(
                    state: &state
                )
                
            case .fetchItemsResult(let result):
                return onFetchItemsResult(
                    state: &state,
                    result: result
                )
                
            case .addItemResult(let result):
                return onAddItemResult(
                    state: &state,
                    result: result
                )
                
            case .deleteItemResult:
                return .none
                
            case .updateItemResult:
                return .none
            }
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension ListItems.Reducer {
    func onViewWillAppear(
        state: inout State
    ) -> Effect<Action> {
        state.isLoading = true
        state.listName = dependencies.list.name
        return .publish(
            dependencies.useCase.fetchItems(
                listId: dependencies.list.documentId)
                .map { .fetchItemsResult(.success($0)) }
                .catch { Just(.fetchItemsResult(.failure($0))) }
                .eraseToAnyPublisher()
        )
    }
    
    func onDidTapAddItemButton(
        state: inout State,
        newItemName: String
    ) -> Effect<Action> {
        return .task(Task {
            .addItemResult(
                await dependencies.useCase.addItem(
                    with: newItemName,
                    listId: dependencies.list.documentId
                )
            )
        })
    }
    
    func onDidTapToggleItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        state.itemsModel.rows[index].done.toggle()
        if let item = state.itemsModel.rows[index] as? Item {
            var list = dependencies.list
            list.done = state.itemsModel.rows.allSatisfy({ $0.done })
            return .task(Task {
                .updateItemResult(
                    await dependencies.useCase.updateItem(
                        item: item,
                        list: list
                    )
                )
            })
        } else {
            state.itemsModel.rows[index].done.toggle()
            return .none
        }
    }
    
    func onDidTapDeleteItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        let itemId = state.itemsModel.rows[index].documentId
        state.itemsModel.rows.remove(at: index)
        return .task(Task {
            .deleteItemResult(
                await dependencies.useCase.deleteItem(
                    itemId: itemId,
                    listId: dependencies.list.documentId
                )
            )
        })
    }
    
    func onDidTapAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        guard !state.itemsModel.rows.contains(
            where: { $0 is EmptyRow }
        ) else {
            return .none
        }
        state.isAddNewItemButtonVisible = false
        state.itemsModel.rows.append(EmptyRow())
        return .none
    }
    
    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.isAddNewItemButtonVisible = true
        state.itemsModel.rows.removeAll { $0 is EmptyRow }
        return .none
    }
    
    func onFetchItemsResult(
        state: inout State,
        result: Result<[Item], Error>
    ) -> Effect<Action> {
        state.isLoading = false
        if case .success(let items) = result {
            state.itemsModel.rows = items
        }
        return .none
    }
    
    func onAddItemResult(
        state: inout State,
        result: Result<Item, Error>
    ) -> Effect<Action> {
        state.isAddNewItemButtonVisible = true
        state.cleanNewItemName = true
        if case .success(let item) = result {
            state.itemsModel.rows.removeAll { $0 is EmptyRow }
            state.itemsModel.rows.append(item)
        }
        return .none
    }
}
