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
        var listName: String = ""
	}

    struct ItemRow: Identifiable, Equatable {
        let id: UUID
		var item: Item
		let leadingActions: [TDSwipeAction]
		let trailingActions: [TDSwipeAction]
		var isEditing: Bool

		init(
            id: UUID = UUID(),
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

extension Array where Element == ListItems.Reducer.ItemRow {
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
