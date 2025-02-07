import SwiftUI
import Entities
import Application
import ListItemsScreenContract

/// Namespace for the ListItems feature components
public struct ListItems {
    /// Builder for creating and configuring ListItems screen instances
    /// Builder responsible for constructing ListItems screen components
    struct Builder {
        /// Creates a new ListItems screen instance
        /// - Parameters:
        ///   - list: List to display and manage items for
        ///   - itemsRepository: Repository for managing items
        /// - Returns: Configured ListItems screen view
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
        
        /// Internal dependencies container for the reducer
        private struct ReducerDependencies: ListItemsReducerDependencies {
            let list: UserList
            let useCase: ListItemsUseCaseApi
        }
    }
}
