import Foundation
import Data
import ThemeComponents

// MARK: - ListItemsViewModel

extension ListItems.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var items = [ItemRow]()
	}

	struct ItemRow: Identifiable {
		let id = UUID()
		var item: Item
		let leadingActions: [TDSwipeAction]
		let trailingActions: [TDSwipeAction]
		var isEditing: Bool

		init(
			item: Item,
			leadingActions: [TDSwipeAction] = [],
			trailingActions: [TDSwipeAction] = [],
			isEditing: Bool = false
		) {
			self.item = item
			self.leadingActions = leadingActions
			self.trailingActions = trailingActions
			self.isEditing = isEditing
		}
	}
}
