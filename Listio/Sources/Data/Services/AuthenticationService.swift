import Foundation
import FirebaseAuth

public final class AuthenticationService {
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
