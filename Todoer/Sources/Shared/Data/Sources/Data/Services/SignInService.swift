import AuthenticationServices
import FirebaseAuth
import Foundation
import GoogleSignIn
import GoogleSignInSwift

public protocol SignInServiceApi {
	func googleSignIn(presentingVC: UIViewController?) async throws -> AuthDataDTO

	func appleSignIn(
		authorization: ASAuthorization
	) async throws -> AuthDataDTO
}

public final class SignInService: SignInServiceApi {
	private enum Errors: Error {
		case signInError
	}
    
    public init() {}

    public func googleSignIn(presentingVC: UIViewController?) async throws -> AuthDataDTO {
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
	) async throws -> AuthDataDTO {
		guard
			let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
			let appleIDToken = appleIDCredential.identityToken,
			let token = String(data: appleIDToken, encoding: .utf8)
		else {
			throw Errors.signInError
		}

		let authCredential = OAuthProvider.credential(
            providerID: .apple,
            accessToken: token
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
    ) async throws -> AuthDataDTO {
		let authDataResult = try await Auth.auth().signIn(with: authCredential)
        return AuthDataDTO(user: authDataResult.user, email: email, displayName: displayName)
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
