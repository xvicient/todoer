import FirebaseAuth
import Foundation

/// Protocol defining the API for authentication services
public protocol AuthenticationServiceApi {
    /// Indicates whether a user is currently logged in
    var isUserLogged: Bool { get }

    /// Signs out the current user
    /// - Throws: Error if sign out fails
    func signOut() throws

    /// Deletes the current user's account
    /// - Throws: Error if deletion fails or no user is logged in
    func delete() async throws
}

/// Implementation of AuthenticationServiceApi using Firebase Authentication
public final class AuthenticationService: AuthenticationServiceApi {
    /// Creates a new authentication service
    public init() {}
    
    /// Indicates whether a user is currently logged in
    public var isUserLogged: Bool {
        Auth.auth().currentUser != nil
    }

    /// Signs out the current user
    /// - Throws: Error if sign out fails
    public func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Deletes the current user's account
    /// - Throws: Error if deletion fails or no user is logged in
    public func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }

        try await user.delete()
    }
}
