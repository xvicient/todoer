import SwiftUI

struct Authentication {
    struct Builder {
        @MainActor
        static func makeAuthentication(
            coordinator: Coordinator
        ) -> AuthenticationView {
            struct Dependencies: AuthenticationReducerDependencies {
                var useCase = Authentication.UseCase()
            }
            return AuthenticationView(
                store: Store(
                    initialState: .init(),
                    reducer: Authentication.Reducer(
                        coordinator: coordinator,
                        dependencies: Dependencies()
                    )
                )
            )
        }
    }
}
