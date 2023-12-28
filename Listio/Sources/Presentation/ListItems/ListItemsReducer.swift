import Combine

protocol ListItemsDependencies {
    var useCase: ListItemsUseCaseApi { get }
    var listId: String { get }
    var listName: String { get }
}

class ItemsModel: ListRowsViewModel {
    var rows: [any ListRowsModel] = []
    var options: (any ListRowsModel) -> [ListRowOption] {
        { _ in
            [ListRowOption]()
        }
    }
}

extension ListItems {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            case viewWillAppear
            case fetchItemsResult(Result<[Item], Error>)
            case didTapAddItemButton(String)
            case addItemResult(Result<Item, Error>)
        }
        
        @MainActor
        struct State {
            var isLoading: Bool = false
            var itemsModel: ItemsModel = ItemsModel()
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
                
            case .didTapAddItemButton(let itemName):
                guard !itemName.isEmpty else { return .none }
                
                state.isLoading = true
                return .task(Task {
                    .addItemResult(
                        try await dependencies.useCase.addItem(with: itemName,
                                                               listId: dependencies.listId)
                    )
                })
                
            case .addItemResult:
                state.isLoading = false
            }
            
            return .none
        }
    }
}
