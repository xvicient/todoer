import SwiftUI
import Data
import Application
import CoordinatorContract

public struct ShareList {
    public struct Builder {
		struct Dependencies: ShareListDependencies {
			var useCase: ShareListUseCaseApi
			var list: UserList
		}

		@MainActor
        public static func makeShareList(
			coordinator: CoordinatorApi,
			list: UserList
		) -> some View {
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
