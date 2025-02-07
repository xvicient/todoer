import AuthenticationScreenContract
import CoordinatorContract
import SwiftUI
import xRedux

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
                        dependencies: dependencies,
                        useCase: UseCase()
                    )
                )
            )
        }
    }
}
