import FirebaseAuth
import Foundation

protocol AuthenticationServiceApi {
	var isUserLogged: Bool { get }

	func signOut() throws

	func delete() async throws
}

public final class AuthenticationService: AuthenticationServiceApi {
	var isUserLogged: Bool {
		Auth.auth().currentUser != nil
	}

	func signOut() throws {
		try Auth.auth().signOut()
	}

	func delete() async throws {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badURL)
		}

		try await user.delete()
	}
}
