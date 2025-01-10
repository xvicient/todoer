import SwiftUI
import Data

struct ShareList {
	struct Builder {
		struct Dependencies: ShareListDependencies {
			var useCase: ShareListUseCaseApi
			var list: UserList
		}

		@MainActor
		static func makeShareList(
			coordinator: Coordinator,
			list: UserList
		) -> ShareListScreen {
			let dependencies = Dependencies(
				useCase: UseCase(),
				list: list
			)
			let reducer = Reducer(
				coordinator: coordinator,
				dependencies: dependencies
			)
			let store = Store(initialState: .init(), reducer: reducer)
			return ShareListScreen(store: store)
		}
	}
}
