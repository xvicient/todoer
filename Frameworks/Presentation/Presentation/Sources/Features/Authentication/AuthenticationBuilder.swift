import SwiftUI

public struct Authentication {
    public struct Builder {
		@MainActor
        public static func makeAuthentication(
			coordinator: Coordinator
		) -> AuthenticationScreen {
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
