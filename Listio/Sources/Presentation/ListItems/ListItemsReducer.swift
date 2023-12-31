import Combine

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var list: List { get }
}

final class ItemsModel: ListRowsViewModel {
    var rows: [any ListRow] = []
    var leadingActions: (any ListRow) -> [ListRowAction] {
        { [$0.done ? .undone : .done] }
    }
    internal var trailingActions = [ListRowAction.delete]
}

extension ListItems {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View flow start
            case viewWillAppear
            
            // MARK: - User actions
            case didTapAddItemButton
            case didTapDoneUndoneButton(any ListRow)
            case didTapDeleteButton(any ListRow)
            
            // MARK: - Results
            case fetchItemsResult(Result<[Item], Error>)
            case addItemResult(Result<Item, Error>)
            case deleteItemResult(Result<Void, Error>)
            case updateItemResult(Result<Item, Error>)
            
            // MARK: - View bindings
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
        
        @MainActor 
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            
            switch action {
            case .viewWillAppear:
                state.isLoading = true
                state.listName = dependencies.list.name
                return .publish(
                    dependencies.useCase.fetchItems(
                        listId: dependencies.list.documentId)
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
                        await dependencies.useCase.addItem(
                            with: name,
                            listId: dependencies.list.documentId
                        )
                    )
                })
                
            case .addItemResult(let result):
                state.isLoading = false
                if case .success = result {
                    state.newItemName = ""
                }
                
            case .didTapDoneUndoneButton(let item):
                state.isLoading = true
                let items = state.itemsModel.rows
                return .task(Task {
                    .updateItemResult(
                        await dependencies.useCase.updateItemDone(
                            item: item,
                            items: items,
                            list: dependencies.list
                        )
                    )
                })
                
            case .updateItemResult:
                state.isLoading = false
                
            case .didTapDeleteButton(let item):
                state.isLoading = true
                state.itemsModel.rows.removeAll { $0.id == item.id }
                return .task(Task {
                    .deleteItemResult(
                        await dependencies.useCase.deleteItem(
                            itemId: item.documentId,
                            listId: dependencies.list.documentId
                        )
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
