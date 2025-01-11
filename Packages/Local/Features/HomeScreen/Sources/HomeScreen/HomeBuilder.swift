import SwiftUI
import Application
import CoordinatorContract

public struct Home {
	public struct Builder {
		struct Dependencies: HomeDependencies {
			var useCase: HomeUseCaseApi
			var coordinator: CoordinatorApi
		}
		@MainActor
		public static func makeHome(
			coordinator: CoordinatorApi
		) -> some View {
			let dependencies = Dependencies(
				useCase: UseCase(),
				coordinator: coordinator
			)
			let reducer = Reducer(dependencies: dependencies)
			let store = Store(initialState: .init(), reducer: reducer)
			return HomeScreen(store: store)
		}
	}
}
