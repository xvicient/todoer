// MARK: - ListItemsReducer

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

extension ListItems {
    struct Reducer: Todoer.Reducer {
        
        enum Action {
            // MARK: - View appear
            /// ListItemsReducer+ViewAppear
            case onAppear
            
            // MARK: - User actions
            /// ListItemsReducer+UserActions
            case didTapToggleItemButton(Int)
            case didTapDeleteItemButton(Int)
            case didTapAddRowButton
            case didTapCancelAddRowButton
            case didTapSubmitItemButton(String)
            case didTapDismissError
            
            // MARK: - Results
            /// ListItemsReducer+Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case updateItemResult(Result<Item, Error>)
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
                
            case (.loading, .fetchItemsResult(let result)),
                (.idle, .fetchItemsResult(let result)):
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
                
            default:
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}
