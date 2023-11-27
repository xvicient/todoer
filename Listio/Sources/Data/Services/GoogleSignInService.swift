import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

final class GoogleSignInService {
    
    @MainActor
    func signIn() async throws -> AuthDataDTO {
        guard let topVC = Utils.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        return try await signIn(credential: credential)
    }
    
    private func signIn(credential: AuthCredential) async throws -> AuthDataDTO {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataDTO(user: authDataResult.user)
    }
}
