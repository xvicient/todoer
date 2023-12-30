import Combine

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var listId: String { get }
    var listName: String { get }
}

class ItemsModel: ListRowsViewModel {
    var rows: [any ListRowsModel] = []
    var leadingActions: (any ListRowsModel) -> [ListRowOption] {
        {
            [$0.done ? .undone : .done]
        }
    }
    internal var trailingActions = [ListRowOption.delete]
}

extension ListItems {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View flow start
            case viewWillAppear
            
            // MARK: - User actions
            case didTapAddItemButton
            case didTapDoneButton(any ListRowsModel)
            case didTapUndoneButton(any ListRowsModel)
            case didTapDeleteButton(any ListRowsModel)
            
            // MARK: - Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            
            // MARK: - State setters
            case setNewItemName(String)
        }
        
        @MainActor
        struct State {
            var isLoading: Bool = false
            var itemsModel: ItemsModel = ItemsModel()
            var newItemName: String = ""
            var listName: String = ""
        }
        
        private let dependencies: ListItemsDependencies
        
        init(dependencies: ListItemsDependencies) {
            self.dependencies = dependencies
        }
        
        @MainActor func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            
            switch action {
            case .viewWillAppear:
                state.isLoading = true
                state.listName = dependencies.listName
                return .publish(
                    dependencies.useCase.fetchItems(
                        listId: dependencies.listId)
                        .map { .fetchItemsResult(.success($0)) }
                        .catch { Just(.fetchItemsResult(.failure($0))) }
                        .eraseToAnyPublisher()
                )
                
            case .fetchItemsResult(let result):
                state.isLoading = false
                if case .success(let items) = result {
                    state.itemsModel.rows = items
                }
                
            case .didTapAddItemButton:
                state.isLoading = true
                let name = state.newItemName
                return .task(Task {
                    .addItemResult(
                        await dependencies.useCase.addItem(with: name,
                                                           listId: dependencies.listId)
                    )
                })
                
            case .addItemResult(let result):
                state.isLoading = false
                if case .success = result {
                    state.newItemName = ""
                }
                
            case .didTapDoneButton:
                break
                
            case .didTapUndoneButton:
                break
                
            case .didTapDeleteButton(let item):
                state.isLoading = true
                return .task(Task {
                    .deleteItemResult(
                        await dependencies.useCase.deleteItem(itemId: item.documentId,
                                                              listId: dependencies.listId)
                    )
                })
                
            case .deleteItemResult:
                state.isLoading = false
            
            case .setNewItemName(let itemName):
                state.newItemName = itemName
            }
            
            return .none
        }
    }
}
