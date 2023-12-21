import SwiftUI

struct Authentication {
    struct Builder {
        @MainActor
        static func makeAuthentication(
            usersRepository: UsersRepositoryApi = UsersRepository(),
            coordinator: Coordinator
        ) -> some View {
            AuthenticationView()
                .environmentObject(
                    Store(
                        initialState: .init(),
                        reducer: reducer,
                        dependencies: Dependencies(),
                        coordinator: coordinator
                    )
                )
        }
    }
}
