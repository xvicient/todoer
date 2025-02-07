import AuthenticationServices
import FirebaseAuth
import Foundation
import GoogleSignIn
import GoogleSignInSwift
import Entities

/// Protocol defining the API for sign-in services
public protocol SignInServiceApi {
    /// Signs in a user using Google authentication
    /// - Parameter presentingVC: View controller to present the Google sign-in UI
    /// - Returns: Authentication data for the signed-in user
    /// - Throws: Error if sign-in fails or if no presenting view controller is provided
    func googleSignIn(presentingVC: UIViewController?) async throws -> AuthData

    /// Signs in a user using Apple authentication
    /// - Parameter authorization: Apple authorization object containing user credentials
    /// - Returns: Authentication data for the signed-in user
    /// - Throws: Error if sign-in fails or if credentials are invalid
    func appleSignIn(
        authorization: ASAuthorization
    ) async throws -> AuthData
}

/// Implementation of SignInServiceApi supporting Google and Apple sign-in
public final class SignInService: SignInServiceApi {
    /// Errors that can occur during sign-in
    private enum Errors: Error {
        /// Generic sign-in error
        case signInError
    }
    
    /// Creates a new sign-in service
    public init() {}

    /// Signs in a user using Google authentication
    /// - Parameter presentingVC: View controller to present the Google sign-in UI
    /// - Returns: Authentication data for the signed-in user
    /// - Throws: Error if sign-in fails or if no presenting view controller is provided
    public func googleSignIn(
        presentingVC: UIViewController?
    ) async throws -> AuthData {
        guard let topVC = presentingVC else {
            throw URLError(.cannotFindHost)
        }

        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }

        let accessToken = gidSignInResult.user.accessToken.tokenString

        let authCredential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        return try await signIn(authCredential: authCredential)
    }

    /// Signs in a user using Apple authentication
    /// - Parameter authorization: Apple authorization object containing user credentials
    /// - Returns: Authentication data for the signed-in user
    /// - Throws: Error if sign-in fails or if credentials are invalid
    public func appleSignIn(
        authorization: ASAuthorization
    ) async throws -> AuthData {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let token = String(data: appleIDToken, encoding: .utf8)
        else {
            throw Errors.signInError
        }

        let authCredential = OAuthProvider.credential(
            providerID: .apple,
            idToken: token
        )

        return try await signIn(
            authCredential: authCredential,
            email: appleIDCredential.email,
            displayName: appleIDCredential.displayName
        )
    }

    /// Common sign-in method used by both Google and Apple authentication
    /// - Parameters:
    ///   - authCredential: Authentication credentials from the provider
    ///   - email: User's email address (optional)
    ///   - displayName: User's display name (optional)
    /// - Returns: Authentication data for the signed-in user
    /// - Throws: Error if Firebase authentication fails
    private func signIn(
        authCredential: AuthCredential,
        email: String? = nil,
        displayName: String? = nil
    ) async throws -> AuthData {
        let user = try await Auth.auth().signIn(with: authCredential).user
        return AuthData(
            uid: user.uid,
            email: email ?? user.email,
            displayName: displayName ?? user.displayName,
            photoUrl: user.photoURL?.absoluteString,
            isAnonymous: user.isAnonymous
        )
    }
}

/// Extension to provide display name formatting for Apple ID credentials
private extension ASAuthorizationAppleIDCredential {
    /// Formats the user's full name from given name and family name
    /// - Returns: Formatted display name or nil if either name component is missing
    var displayName: String? {
        guard let givenName = fullName?.givenName,
            let familyName = fullName?.familyName
        else { return nil }
        
        return "\(givenName) \(familyName)"
    }
}
