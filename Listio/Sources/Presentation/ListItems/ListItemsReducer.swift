import Combine
import SwiftUI
import Foundation

// MARK: - ListItemsReducer

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

internal final class ViewModel: ListRowsViewModel {
    var rows: [any ListRow] = []
    var leadingActions: (any ListRow) -> [ListRowActionType] {
        { [$0.done ? .undone : .done] }
    }
    var trailingActions = [ListRowActionType.delete]
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
            // MARK: - View appear
            case onAppear
            
            // MARK: - User actions
            case didTapToggleItemButton(Int)
            case didTapDeleteItemButton(Int)
            case didTapAddRowButton
            case didTapCancelAddRowButton
            case didTapSubmitItemButton(String)
            
            // MARK: - Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case updateItemResult(Result<Item, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }
        
        enum ViewState {
            case idle
            case loading
            case addingItem
            case unexpectedError
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
            
            switch (state.viewState, action) {
            case (.idle, .onAppear):
                return onAppear(
                    state: &state
                )
                
            case (.idle, .didTapToggleItemButton(let index)):
                return onDidTapToggleItemButton(
                    state: &state,
                    index: index
                )
                
            case (.idle, .didTapDeleteItemButton(let index)):
                return onDidTapDeleteItemButton(
                    state: &state,
                    index: index
                )
            
            case (.idle, .didTapAddRowButton):
                return onDidTapAddRowButton(
                    state: &state
                )
            
            case (.addingItem, .didTapCancelAddRowButton):
                return onDidTapCancelAddRowButton(
                    state: &state
                )
                
            case (.addingItem, .didTapSubmitItemButton(let newItemName)):
                return onDidTapSubmitItemButton(
                    state: &state,
                    newItemName: newItemName
                )
                
            case (.loading, .fetchItemsResult(let result)):
                return onFetchItemsResult(
                    state: &state,
                    result: result
                )
                
            case (.addingItem, .addItemResult(let result)):
                return onAddItemResult(
                    state: &state,
                    result: result
                )
                
            case (.idle, .deleteItemResult):
                return .none
                
            case (.idle, .updateItemResult):
                return .none
                
            case (_, .didTapDismissError):
                return onDidTapDismissError(
                    state: &state
                )
            
            default: return .none
            }
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension ListItems.Reducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .publish(
            dependencies.useCase.fetchItems(
                listId: dependencies.list.documentId)
                .map { .fetchItemsResult(.success($0)) }
                .catch { Just(.fetchItemsResult(.failure($0))) }
                .eraseToAnyPublisher()
        )
    }
    
    func onDidTapToggleItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        state.viewModel.rows[index].done.toggle()
        if let item = state.viewModel.rows[index] as? Item {
            var list = dependencies.list
            list.done = state.viewModel.rows.allSatisfy({ $0.done })
            return .task(Task {
                .updateItemResult(
                    await dependencies.useCase.updateItem(
                        item: item,
                        list: list
                    )
                )
            })
        } else {
            state.viewModel.rows[index].done.toggle()
            return .none
        }
    }
    
    func onDidTapDeleteItemButton(
        state: inout State,
        index: Int
    ) -> Effect<Action> {
        let itemId = state.viewModel.rows[index].documentId
        state.viewModel.rows.remove(at: index)
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
        guard !state.viewModel.rows.contains(
            where: { $0 is EmptyRow }
        ) else {
            return .none
        }
        state.viewState = .addingItem
        state.viewModel.rows.append(EmptyRow())
        return .none
    }
    
    func onDidTapCancelAddRowButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.rows.removeAll { $0 is EmptyRow }
        return .none
    }
    
    func onDidTapSubmitItemButton(
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
    
    func onFetchItemsResult(
        state: inout State,
        result: Result<[Item], Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            state.viewState = .idle
            state.viewModel.rows = items
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onAddItemResult(
        state: inout State,
        result: Result<Item, Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            state.viewState = .idle
            state.viewModel.rows.removeAll { $0 is EmptyRow }
            state.viewModel.rows.append(item)
        case .failure:
            state.viewState = .unexpectedError
        }
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
