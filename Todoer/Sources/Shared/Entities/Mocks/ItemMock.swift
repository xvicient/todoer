import Foundation
import Entities
import Common

/// Mock data generator for Item entities
public struct ItemMock {
    /// Returns a single mock item
    /// Convenience accessor for the first item in a collection of one
    public static var item: Item {
        items(1).first!
    }

    /// Generates an array of mock items
    /// - Parameter count: Number of mock items to generate
    /// - Returns: Array of mock items with sequential IDs, indices, and names
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
