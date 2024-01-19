import Foundation
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

protocol SignInServiceApi {
    func googleSignIn(
    ) async throws -> AuthDataDTO
    
    func appleSignIn(
        authorization: ASAuthorization
    ) async throws -> AuthDataDTO
}

final class SignInService: SignInServiceApi {
    private enum Errors: Error {
        case signInError
    }
    
    @MainActor
    func googleSignIn() async throws -> AuthDataDTO {
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
    
    @MainActor
    func appleSignIn(
        authorization: ASAuthorization
    ) async throws -> AuthDataDTO {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let token = String(data: appleIDToken, encoding: .utf8) else {
            throw Errors.signInError
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: token,
            rawNonce: nil
        )
        
        var authData = try await signIn(credential: credential)
        if let email = appleIDCredential.email {
            authData.email = email
        }
        
        if let givenName = appleIDCredential.fullName?.givenName,
           let familyName = appleIDCredential.fullName?.familyName{
            authData.displayName = "\(givenName) \(familyName)"
        }
        
        return authData
    }
    
    private func signIn(credential: AuthCredential) async throws -> AuthDataDTO {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataDTO(user: authDataResult.user)
    }
}
