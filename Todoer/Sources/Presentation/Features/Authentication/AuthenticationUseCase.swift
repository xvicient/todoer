import AuthenticationServices

protocol AuthenticationUseCaseApi {
    func singIn(
        authType: Authentication.Provider
    ) async -> (Result<Void, Error>)
}

extension Authentication {
    enum Provider {
        case apple(ASAuthorization)
        case google
    }
    struct UseCase: AuthenticationUseCaseApi {
        private enum Errors: Error {
            case emailInUse
            case emptyAuthEmail
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
            authType: Authentication.Provider
        ) async -> (Result<Void, Error>) {
            do {
                var authData: AuthDataDTO
                
                switch authType {
                case .apple(let authorization):
                    authData = try await singInService.appleSignIn(authorization: authorization)
                case .google:
                    authData = try await singInService.googleSignIn()
                }
                
                guard let email = authData.email else {
                    throw Errors.emptyAuthEmail
                }
                
                guard try await usersRepository.getNotSelfUser(email: email) == nil else {
                    throw Errors.emailInUse
                }
                
                if (try? await usersRepository.getUser(uid: authData.uid)) == nil {
                    try await usersRepository.createUser(with: authData.uid,
                                                         email: authData.email,
                                                         displayName: authData.displayName,
                                                         photoUrl: authData.photoUrl)
                }
                
                usersRepository.setUuid(authData.uid)
                
                return .success(())
            } catch {
                try? authenticationService.signOut()
                return .failure(error)
            }
        }
    }
}
