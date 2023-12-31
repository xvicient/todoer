import SwiftUI

struct ListItems {
    struct Builder {
        struct Dependencies: ListItemsDependencies {
            var useCase: ListItemsUseCaseApi
            var list: List
        }
        
        @MainActor
        static func makeItemsList(
            list: List
        ) -> ListItemsView {
            let dependencies = Dependencies(
                useCase: ListItems.UseCase(),
                list: list
            )
            let reducer = ListItems.Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return ListItemsView(store: store)
        }
    }
}
