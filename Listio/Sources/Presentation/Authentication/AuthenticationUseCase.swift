extension Authentication {
    struct UseCase {
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
            
            usersRepository.createUser(with: authData.uid,
                                       email: authData.email,
                                       displayName: authData.displayName)
            { result in
                switch result {
                case .success:
                    break
                case .failure:
                    break
                }
            }
        }
    }
}
