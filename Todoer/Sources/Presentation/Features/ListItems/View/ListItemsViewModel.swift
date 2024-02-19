import Foundation

// MARK: - ListItemsViewModel

internal extension ListItems.Reducer {
    
    // MARK: - ViewModel
    
    @MainActor
    struct ViewModel {
        var items = [ItemRow]()
    }
    
    struct ItemRow: Identifiable {
        let id = UUID()
        var item: Item
        let leadingActions: [TDSwipeActionOption]
        let trailingActions: [TDSwipeActionOption]
        var isEditing: Bool
        
        init(item: Item,
             leadingActions: [TDSwipeActionOption] = [],
             trailingActions: [TDSwipeActionOption] = [],
             isEditing: Bool = false) {
            self.item = item
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.isEditing = isEditing
        }
    }
}
