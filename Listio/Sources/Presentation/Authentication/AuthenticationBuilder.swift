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
                        reducer: Authentication.Reducer(
                            coordinator: coordinator,
                            useCase: Authentication.UseCase()
                        )
                    )
                )
        }
    }
}
