import SwiftUI

struct AuthenticationBuilder {
    @MainActor
    static func makeAuthentication(
        usersRepository: UsersRepositoryApi = UsersRepository()
    ) -> AuthenticationView {
        AuthenticationView(
            viewModel: AuthenticationViewModel(
                usersRepository: usersRepository
            )
        )
    }
}
