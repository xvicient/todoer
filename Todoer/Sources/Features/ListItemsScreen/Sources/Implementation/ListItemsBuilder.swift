import Entities
import ListItemsScreenContract
import SwiftUI
import xRedux

public struct ListItems {
    public struct Builder {
        private struct ReducerDependencies: ListItemsReducerDependencies {
            let list: UserList
            let useCase: ListItemsUseCaseApi
        }

        @MainActor
        public static func makeItemsList(
            dependencies: ListItemsScreenDependencies
        ) -> some View {
            ListItemsScreen(
                store: Store(
                    initialState: .init(),
                    reducer: Reducer(
                        dependencies: ReducerDependencies(
                            list: dependencies.list,
                            useCase: UseCase()
                        )
                    )
                )
            )
        }
    }
}
