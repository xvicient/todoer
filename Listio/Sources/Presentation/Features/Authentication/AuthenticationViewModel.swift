import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    func signInGoogle() async throws {
        let googleService = GoogleSignInService()
        let authData = try await googleService.signIn()
        print(authData)
    }
}
