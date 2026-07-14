import Entities
import ListItemsScreenContract
import SwiftUI
import xRedux

public struct ListItemsBuilder {
    @MainActor
    public static func makeItemsList(
        dependencies: ListItemsScreenDependencies
    ) -> some View {
        ListItemsScreen(
            store: Store(
                initialState: .init(listName: dependencies.list.name),
                reducer: ListItemsReducer(
                    useCase: ListItemsUseCase(list: dependencies.list)
                )
            )
        )
    }
}
