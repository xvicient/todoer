import Foundation
import Entities
import ThemeComponents
import Entities
import Common

// MARK: - ListItemsViewModel

extension ListItems.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var items = [WrappedItem]()
        var listName: String = ""
	}

    struct WrappedItem: Identifiable, Equatable, ElementSortable {
        let id: UUID
		var item: Item
		let leadingActions: [TDSwipeAction]
		let trailingActions: [TDSwipeAction]
		var isEditing: Bool
        
        var done: Bool { item.done }
        var name: String { item.name }
        var index: Int {
            get {
                item.index
            }
            set {
                item.index = newValue
            }
        }

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
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
