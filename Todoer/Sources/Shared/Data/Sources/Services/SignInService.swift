import AuthenticationServices
import FirebaseAuth
import Foundation
import GoogleSignIn
import GoogleSignInSwift
import Entities

public protocol SignInServiceApi {
	func googleSignIn(presentingVC: UIViewController?) async throws -> AuthData

	func appleSignIn(
		authorization: ASAuthorization
	) async throws -> AuthData
}

public final class SignInService: SignInServiceApi {
	private enum Errors: Error {
		case signInError
	}
    
    public init() {}

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

private extension ASAuthorizationAppleIDCredential {
    var displayName: String? {
        guard let givenName = fullName?.givenName,
            let familyName = fullName?.familyName
        else { return nil }
        
        return "\(givenName) \(familyName)"
    }
}
