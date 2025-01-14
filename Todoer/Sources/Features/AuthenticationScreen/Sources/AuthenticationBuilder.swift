import SwiftUI
import Application
import CoordinatorContract
import AuthenticationScreenContract

public struct Authentication {
	public struct Builder {
		@MainActor
		public static func makeAuthentication(
            dependencies: AuthenticationScreenDependencies
        ) -> some View {
			AuthenticationScreen(
				store: Store(
					initialState: .init(),
					reducer: Authentication.Reducer(
						dependencies: dependencies
					)
				)
			)
		}
	}
}
