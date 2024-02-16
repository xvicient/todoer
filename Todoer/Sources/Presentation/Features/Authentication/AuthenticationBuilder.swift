import SwiftUI

struct Authentication {
    struct Builder {
        @MainActor
        static func makeAuthentication(
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
