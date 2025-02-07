import Entities
import Foundation

public struct ListMock {
    public static var list: UserList {
        lists(1).first!
    }

    static func lists(_ count: Int) -> [UserList] {
        (0..<count).map {
            UserList(
                id: UUID(),
                documentId: String($0),
                name: String($0),
                done: false,
                uid: [String($0)],
                index: $0
            )
        }
    }
}
