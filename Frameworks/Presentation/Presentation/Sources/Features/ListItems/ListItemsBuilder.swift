import Common
import SwiftUI

struct ListItems {
	struct Builder {
		struct Dependencies: ListItemsDependencies {
			var useCase: ListItemsUseCaseApi
			var list: Common.List
		}

		@MainActor
		static func makeItemsList(
			list: Common.List
		) -> ListItemsScreen {
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
