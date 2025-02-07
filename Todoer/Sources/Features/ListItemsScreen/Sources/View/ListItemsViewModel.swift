import Foundation
import Entities
import ThemeComponents
import Entities

// MARK: - ListItemsViewModel

extension ListItems.Reducer {

	// MARK: - ViewModel

	/// View model containing the data needed to display the ListItems screen
	@MainActor
	struct ViewModel {
		/// Array of wrapped items to display in the list
		var items = [WrappedItem]()
        /// Name of the current list
        var listName: String = ""
	}

    /// A wrapper around an Item that includes UI-specific properties
    struct WrappedItem: Identifiable, Equatable {
        /// Unique identifier for the wrapped item
        let id: UUID
		/// The underlying item
		var item: Item
		/// Swipe actions available on the leading edge
		let leadingActions: [TDSwipeAction]
		/// Swipe actions available on the trailing edge
		let trailingActions: [TDSwipeAction]
		/// Whether the item is being edited
		var isEditing: Bool

		/// Creates a new wrapped item
		/// - Parameters:
		///   - id: Unique identifier for the item
		///   - item: The underlying item to wrap
		///   - leadingActions: Array of leading swipe actions
		///   - trailingActions: Array of trailing swipe actions
		///   - isEditing: Whether the item is in editing mode
		init(
            id: UUID,
			item: Item,
			leadingActions: [TDSwipeAction] = [],
			trailingActions: [TDSwipeAction] = [],
			isEditing: Bool = false
		) {
            self.id = id
			self.item = item
			self.leadingActions = leadingActions
			self.trailingActions = trailingActions
			self.isEditing = isEditing
		}
	}
}

extension Array where Element == ListItems.Reducer.WrappedItem {
    /// Finds the index of a wrapped item by its ID
    /// - Parameter id: The ID to search for
    /// - Returns: The index of the item if found, nil otherwise
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
