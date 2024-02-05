import AuthenticationServices

protocol AuthenticationUseCaseApi {
    func singIn(
        provider: Authentication.Provider
    ) async -> ActionResult<EquatableVoid>
}

extension Authentication {
    enum Provider {
        case apple(ASAuthorization)
        case google
        
        var value: String {
            switch self {
            case .apple:
                "apple"
            case .google:
                "google"
            }
        }
    }
    struct UseCase: AuthenticationUseCaseApi {
        private enum Errors: Error, LocalizedError {
            case emailInUse
            case emptyAuthEmail
            
            var errorDescription: String? {
                switch self {
                case .emailInUse:
                    return "Email already in use with another provider."
                case .emptyAuthEmail:
                    return "Invalid email."
                }
            }
        }
        
        private let usersRepository: UsersRepositoryApi
        private let singInService: SignInServiceApi
        private let authenticationService: AuthenticationServiceApi
        
        init(usersRepository: UsersRepositoryApi = UsersRepository(),
             singInService: SignInServiceApi = SignInService(),
             authenticationService: AuthenticationServiceApi = AuthenticationService()) {
            self.usersRepository = usersRepository
            self.singInService = singInService
            self.authenticationService = authenticationService
        }
        
        func singIn(
            provider: Authentication.Provider
        ) async -> ActionResult<EquatableVoid> {
            do {
                let authData = try await getAuthData(for: provider)
                
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
                    try await usersRepository.createUser(with: authData.uid,
                                                         email: authData.email,
                                                         displayName: authData.displayName,
                                                         photoUrl: authData.photoUrl,
                                                         provider: provider.value)
                }
                
                usersRepository.setUuid(authData.uid)
                
                return .success()
            } catch {
                try? authenticationService.signOut()
                return .failure(error)
            }
        }
        
        private func getAuthData(
            for provider: Provider
        ) async throws -> AuthDataDTO {
            switch provider {
            case .apple(let authorization):
                return try await singInService.appleSignIn(authorization: authorization)
            case .google:
                return try await singInService.googleSignIn()
            }
        }
    }
}
