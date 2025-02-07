/// Protocol defining the business logic operations for authentication
protocol AuthenticationUseCaseApi {
    /// Signs in a user using the specified provider
    /// - Parameters:
    ///   - provider: Authentication provider to use
    ///   - window: Window for presenting auth UI
    /// - Returns: Result indicating success or error
    func singIn(
        provider: Authentication.Provider,
        window: UIWindow
    ) async -> ActionResult<EquatableVoid>
}

extension Authentication {
    /// Enumeration of supported authentication providers
    enum Provider {
        /// Apple Sign In with ASAuthorization
        case apple(ASAuthorization)
        /// Google Sign In
        case google

        /// String representation of the provider
        var value: String {
            switch self {
            case .apple:
                "apple"
            case .google:
                "google"
            }
        }
    }

    /// Implementation of authentication use cases
    final class UseCase: AuthenticationUseCaseApi {
        /// Repository for managing authentication
        private let authenticationService: AuthenticationServiceApi
        /// Repository for managing users
        private let usersRepository: UsersRepositoryApi

        /// Initializes the use case with required repositories
        /// - Parameters:
        ///   - authRepository: Repository for authentication operations
        ///   - usersRepository: Repository for user operations
        init(
            authenticationService: AuthenticationServiceApi = AuthenticationService(),
            usersRepository: UsersRepositoryApi = UsersRepository()
        ) {
            self.authenticationService = authenticationService
            self.usersRepository = usersRepository
        }

        /// Signs in a user using the specified provider
        /// - Parameters:
        ///   - provider: Authentication provider to use
        ///   - window: Window for presenting auth UI
        /// - Returns: Result indicating success or error
        func singIn(
            provider: Authentication.Provider,
            window: UIWindow
        ) async -> ActionResult<EquatableVoid> {
            do {
                let authData = try await getAuthData(for: provider, window: window)
                
                guard !authData.uid.isEmpty else {
                    throw Errors.emptyUid
                }
                
                guard let email = authData.email else {
                    throw Errors.emptyAuthEmail
                }

                if let notSelfUser = try await usersRepository.getNotSelfUser(
                    email: email,
                    uid: authData.uid
                ), notSelfUser.provider != provider.value {
                    throw Errors.emailInUse
                }

                if (try? await usersRepository.getUser(uid: authData.uid)) == nil {
                    try await usersRepository.createUser(
                        with: authData.uid,
                        email: authData.email,
                        displayName: authData.displayName,
                        photoUrl: authData.photoUrl,
                        provider: provider.value
                    )
                }

                usersRepository.setUid(authData.uid)

                return .success()
            }
            catch {
                try? authenticationService.signOut()
                return .failure(error)
            }
        }

        /// Retrieves authentication data for a specific provider
        /// - Parameter provider: The authentication provider
        /// - Parameter window: Window for presenting auth UI
        /// - Returns: Authentication data containing user information
        private func getAuthData(
            for provider: Provider,
            window: UIWindow
        ) async throws -> AuthData {
            switch provider {
            case .apple(let authorization):
                return try await authenticationService.appleSignIn(
                    authorization: authorization
                )
            case .google:
                return try await authenticationService.googleSignIn(
                    presentingVC: Utils.topViewController()
                )
            }
        }
    }
}

private enum Errors: Error, LocalizedError {
    /// Error when the email is already in use with another provider
    case emailInUse
    /// Error when the authentication email is empty
    case emptyAuthEmail
    /// Error when the user ID is empty
    case emptyUid

    var errorDescription: String? {
        switch self {
        case .emailInUse:
            return "Email already in use with another provider."
        case .emptyAuthEmail:
            return "Invalid email."
        case .emptyUid:
            return "Empty uid."
        }
    }
}
