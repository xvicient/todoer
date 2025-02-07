import Entities

/// Mock data generator for User entities
public struct UserMock {
    /// Returns a single mock user
    /// Convenience accessor for the first user in a collection of one
    static var user: User {
        users(1).first!
    }

    /// Generates an array of mock users
    /// - Parameter count: Number of mock users to generate
    /// - Returns: Array of mock users with sequential IDs
    public static func users(_ count: Int) -> [User] {
        (0..<count).map {
            User(
                documentId: String($0),
                uid: String($0),
                provider: "todoer"
            )
        }
    }
}
