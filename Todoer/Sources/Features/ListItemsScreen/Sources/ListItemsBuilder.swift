import SwiftUI
import Entities
import Application
import ListItemsScreenContract

public struct ListItems {
    public struct Builder {
		@MainActor
        public static func makeItemsList(
            dependencies: ListItemsDependencies
		) -> some View {
			let reducer = Reducer(dependencies: dependencies)
			let store = Store(initialState: .init(), reducer: reducer)
			return ListItemsScreen(
				store: store,
                listName: dependencies.list.name
			)
		}
	}
}
