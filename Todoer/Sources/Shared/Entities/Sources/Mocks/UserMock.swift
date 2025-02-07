import Entities

public struct UserMock {
    static var user: User {
        users(1).first!
    }

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
