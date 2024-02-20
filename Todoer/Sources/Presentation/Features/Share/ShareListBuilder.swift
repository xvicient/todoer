import SwiftUI

struct ShareList {
	struct Builder {
		struct Dependencies: ShareListDependencies {
			var useCase: ShareListUseCaseApi
			var list: List
		}

		@MainActor
		static func makeShareList(
			coordinator: Coordinator,
			list: List
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
