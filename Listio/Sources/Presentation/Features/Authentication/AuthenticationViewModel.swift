import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    let usersRepository: UsersRepositoryApi
    let googleService: GoogleSignInServiceApi
    
    init(usersRepository: UsersRepositoryApi,
         googleService: GoogleSignInServiceApi = GoogleSignInService()) {
        self.usersRepository = usersRepository
        self.googleService = googleService
    }
    
    func signInGoogle() async throws {
        let authData = try await googleService.signIn()
        
        usersRepository.createUser(with: authData.uid,
                                   email: authData.email,
                                   displayName: authData.displayName,
                                   completion: { _ in
            
        })
    }
}
