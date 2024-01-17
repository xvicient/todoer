import AuthenticationServices

protocol AuthenticationUseCaseApi {
    func googleSignIn(
    ) async -> (Result<Void, Error>)
    
    func appleSignIn(
        authorization: ASAuthorization
    ) async -> (Result<Void, Error>)
}

extension Authentication {
    struct UseCase: AuthenticationUseCaseApi {
        private enum Errors: Error {
            case signInError
        }
        private let usersRepository: UsersRepositoryApi
        private let singInService: SignInServiceApi
        
        init(usersRepository: UsersRepositoryApi = UsersRepository(),
             singInService: SignInServiceApi = SignInService()) {
            self.usersRepository = usersRepository
            self.singInService = singInService
        }
        
        func googleSignIn() async -> (Result<Void, Error>) {
            do {
                let authData = try await singInService.googleSignIn()
                try await setUser(authData: authData)
                
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func appleSignIn(
            authorization: ASAuthorization
        ) async -> (Result<Void, Error>) {
            do {
                let authData = try await singInService.appleSignIn(authorization: authorization)
                try await setUser(authData: authData)
                
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        private func setUser(
            authData: AuthDataDTO
        ) async throws {
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
