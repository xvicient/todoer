import SwiftUI

struct ListItems {
    struct Builder {
        struct Dependencies: ListItemsDependencies {
            var useCase: ListItemsUseCaseApi
            var listId: String
            var listName: String
        }
        
        @MainActor
        static func makeProductList(
            list: List
        ) -> ListItemsView {
            let dependencies = Dependencies(
                useCase: ListItems.UseCase(),
                listId: list.documentId,
                listName: list.name
            )
            let reducer = ListItems.Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return ListItemsView(store: store)
        }
    }
}
