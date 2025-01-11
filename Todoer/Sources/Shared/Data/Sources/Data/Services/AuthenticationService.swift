import FirebaseAuth
import Foundation

public protocol AuthenticationServiceApi {
	var isUserLogged: Bool { get }

	func signOut() throws

	func delete() async throws
}

public final class AuthenticationService: AuthenticationServiceApi {
    public init() {}
    
    public var isUserLogged: Bool {
		Auth.auth().currentUser != nil
	}

    public func signOut() throws {
		try Auth.auth().signOut()
	}

    public func delete() async throws {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badURL)
		}

		try await user.delete()
	}
}
