import Entities
import ListItemsScreenContract
import SwiftUI
import xRedux

public struct ListItemsBuilder {
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
                initialState: .init(listName: dependencies.list.name),
                reducer: ListItemsReducer(
                    dependencies: ReducerDependencies(
                        list: dependencies.list,
                        useCase: ListItemsUseCase()
                    )
                )
            )
        )
    }
}
