import Foundation

// MARK: - ListItemsReducer

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

extension ListItems {
    struct Reducer: Todoer.Reducer {
        
        enum Errors: Error, LocalizedError {
            case unexpectedError
            
            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }
            
            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }
        
        enum Action {
            // MARK: - View appear
            /// ListItemsReducer+ViewAppear
            case onAppear
            
            // MARK: - User actions
            /// ListItemsReducer+UserActions
            case didTapToggleItemButton(Int)
            case didTapDeleteItemButton(Int)
            case didTapAddItemButton
            case didTapCancelAddItemButton
            case didTapSubmitItemButton(String)
            case didTapEditItemButton(Int)
            case didTapUpdateItemButton(Int, String)
            case didTapCancelEditItemButton(Int)
            case didSortItems(IndexSet, Int)
            case didTapDismissError
            
            // MARK: - Results
            /// ListItemsReducer+Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case toggleItemResult(Result<Item, Error>)
            case sortItemsResult(Result<Void, Error>)
        }
        
        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }
        
        enum ViewState: Equatable {
            case idle
            case loading
            case addingItem
            case updatingItem
            case editingItem
            case sortingItems
            case error(String)
        }
        
        internal let dependencies: ListItemsDependencies
        
        init(dependencies: ListItemsDependencies) {
            self.dependencies = dependencies
        }
        
        // MARK: - Reduce
        
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
                
            case (.idle, .didTapAddItemButton):
                return onDidTapAddRowButton(
                    state: &state
                )
                
            case (.addingItem, .didTapCancelAddItemButton):
                return onDidTapCancelAddRowButton(
                    state: &state
                )
                
            case (.addingItem, .didTapSubmitItemButton(let newItemName)):
                return onDidTapSubmitItemButton(
                    state: &state,
                    newItemName: newItemName
                )
                
            case (.loading, .fetchItemsResult(let result)),
                (.idle, .fetchItemsResult(let result)):
                return onFetchItemsResult(
                    state: &state,
                    result: result
                )
                
            case (.addingItem, .addItemResult(let result)),
                (.editingItem, .addItemResult(let result)):
                return onAddItemResult(
                    state: &state,
                    result: result
                )
                
            case (.idle, .deleteItemResult):
                return .none
                
            case (.updatingItem, .toggleItemResult(let result)):
                return onToggleItemResult(
                    state: &state,
                    result: result
                )
                
            case (.idle, .didTapEditItemButton(let index)):
                return onDidTapEditItemButton(
                    state: &state,
                    index: index
                )
                
            case (.editingItem, .didTapCancelEditItemButton(let index)):
                return onDidTapCancelEditItemButton(
                    state: &state,
                    index: index
                )
                
            case (.editingItem, .didTapUpdateItemButton(let index, let name)):
                return onDidTapUpdateItemButton(
                    state: &state,
                    index: index,
                    name: name
                )
                
            case (.idle, .didSortItems(let fromIndex, let toIndex)):
                return onDidSortItems(
                    state: &state,
                    fromIndex: fromIndex,
                    toIndex: toIndex
                )
                
            case (.sortingItems, .sortItemsResult(let result)):
                return onSortItemsResult(
                    state: &state,
                    result: result
                )
                
            case (.error, .didTapDismissError):
                return onDidTapDismissError(
                    state: &state
                )
                
            default:
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}

// MARK: - Item to ItemRow

internal extension Item {
    var toItemRow: ListItems.Reducer.ItemRow {
        ListItems.Reducer.ItemRow(
            item: self,
            leadingActions: [self.done ? .undone : .done],
            trailingActions: [.delete, .edit]
        )
    }
}
