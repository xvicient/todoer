import SwiftUI

struct Authentication {
    struct Builder {
        @MainActor
        static func makeAuthentication(
            coordinator: Coordinator
        ) -> AuthenticationView {
            struct Dependencies: AuthenticationDependencies {
                var useCase: AuthenticationUseCaseApi
            }
            return AuthenticationView(
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
