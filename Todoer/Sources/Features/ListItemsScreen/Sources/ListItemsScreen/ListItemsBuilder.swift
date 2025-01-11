import SwiftUI
import Entities
import Application

public struct ListItems {
    public struct Builder {
		struct Dependencies: ListItemsDependencies {
			var useCase: ListItemsUseCaseApi
			var list: UserList
		}

		@MainActor
        public static func makeItemsList(
			list: UserList
		) -> some View {
			let dependencies = Dependencies(
				useCase: UseCase(),
				list: list
			)
			let reducer = Reducer(dependencies: dependencies)
			let store = Store(initialState: .init(), reducer: reducer)
			return ListItemsScreen(
				store: store,
				listName: list.name
			)
		}
	}
}
