import SwiftUI

public class TDListRow: ObservableObject, Identifiable {
    public let id: UUID
    var name: String
    var image: Image
    @Published var strikethrough: Bool
    let leadingActions: [TDSwipeAction]
    let trailingActions: [TDSwipeAction]
    var isEditing: Bool

    public init(
        id: UUID,
        name: String,
        image: Image,
        strikethrough: Bool,
        leadingActions: [TDSwipeAction] = [],
        trailingActions: [TDSwipeAction] = [],
        isEditing: Bool = false
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.strikethrough = strikethrough
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.isEditing = isEditing
    }
}
