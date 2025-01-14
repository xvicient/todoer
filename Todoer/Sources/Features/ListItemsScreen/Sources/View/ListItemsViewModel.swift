import Foundation
import Entities
import ThemeComponents
import Entities

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

extension Array where Element == ListItems.Reducer.ItemRow {
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
