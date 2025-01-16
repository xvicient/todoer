import Foundation
import Entities
import Common

public struct ItemMock {
    public static var item: Item {
        items(1).first!
    }

    public static func items(_ count: Int) -> [Item] {
        (0..<count).map {
            Item(
                id: $0.uuid,
                documentId: String($0),
                name: "Item \($0)",
                done: false,
                index: $0
            )
        }
    }
}
