protocol AuthenticationUseCaseApi {
    func signIn() async throws
}

extension Authentication {
    struct UseCase: AuthenticationUseCaseApi {
        private enum Errors: Error {
            case signInError
        }
        private let usersRepository: UsersRepositoryApi
        private let googleService: GoogleSignInServiceApi
        
        init(usersRepository: UsersRepositoryApi = UsersRepository(),
             googleService: GoogleSignInServiceApi = GoogleSignInService()) {
            self.usersRepository = usersRepository
            self.googleService = googleService
        }
        
        func signIn() async throws {
            let authData = try await googleService.signIn()
            
            guard let email = authData.email else {
                throw Errors.signInError
            }
            
            if (try? await usersRepository.getUser(email)) == nil {
                try await usersRepository.createUser(with: authData.uid,
                                                     email: authData.email,
                                                     displayName: authData.displayName,
                                                     photoUrl: authData.photoUrl)
            }
            
            usersRepository.setUuid(authData.uid)
        }
    }
}
