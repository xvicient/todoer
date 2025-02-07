import SwiftUI

/// A model representing a row in a TDList
/// Contains all the necessary information to display a list item including swipe actions
public struct TDListRow: Identifiable {
    public let id: UUID
	var name: String
	var image: Image
	var strikethrough: Bool
	let leadingActions: [TDSwipeAction]
	let trailingActions: [TDSwipeAction]
	var isEditing: Bool

    /// Creates a new list row
    /// - Parameters:
    ///   - id: Unique identifier for the row
    ///   - name: Display text for the row
    ///   - image: Icon to display with the row
    ///   - strikethrough: Whether to show the text with a strikethrough
    ///   - leadingActions: Array of swipe actions for the leading edge
    ///   - trailingActions: Array of swipe actions for the trailing edge
    ///   - isEditing: Whether the row is in editing mode
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
