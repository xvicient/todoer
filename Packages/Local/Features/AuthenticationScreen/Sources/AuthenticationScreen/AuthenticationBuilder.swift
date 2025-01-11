import SwiftUI
import Application
import CoordinatorContract

public struct Authentication {
	public struct Builder {
		@MainActor
		public static func makeAuthentication(
            coordinator: CoordinatorApi
        ) -> some View {
			struct Dependencies: AuthenticationDependencies {
				var useCase: AuthenticationUseCaseApi
			}
			return AuthenticationScreen(
				store: Store(
					initialState: .init(),
					reducer: Authentication.Reducer(
						coordinator: coordinator,
						dependencies: Dependencies(
							useCase: Authentication.UseCase()
						)
					)
				)
			)
		}
	}
}
