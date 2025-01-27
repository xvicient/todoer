import FirebaseAuth
import Foundation
import Common

public protocol AuthenticationServiceApi {
	var isUserLogged: Bool { get }

	func signOut() throws

	func delete() async throws
}

public final class AuthenticationService: AuthenticationServiceApi {
    private enum Errors: Error, LocalizedError {
        case noAuthUser

        var errorDescription: String? {
            switch self {
            case .noAuthUser:
                return "No auth user."
            }
        }
    }
    
    @AppSetting(key: "uid", defaultValue: "") private var uid: String
    
    public init() {}
    
    public var isUserLogged: Bool {
        authUser != nil && !uid.isEmpty
    }

    public func signOut() throws {
		try Auth.auth().signOut()
	}

    public func delete() async throws {
		guard let user = authUser else {
            throw Errors.noAuthUser
		}

		try await user.delete()
	}
    
    private var authUser: User? {
        Auth.auth().currentUser ?? (try? Auth.auth().getStoredUser(forAccessGroup: UserDefaults.appGroup))
    }
}
