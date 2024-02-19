import Foundation

internal extension Home.Reducer {
    
    // MARK: - ViewModel
    
    @MainActor
    struct ViewModel {
        var lists = [ListRow]()
        var invitations = [Invitation]()
        var photoUrl = ""
    }
    
    struct ListRow: Identifiable {
        let id = UUID()
        var list: List
        let leadingActions: [TDSwipeActionOption]
        let trailingActions: [TDSwipeActionOption]
        var isEditing: Bool
        
        init(list: List,
             leadingActions: [TDSwipeActionOption] = [],
             trailingActions: [TDSwipeActionOption] = [],
             isEditing: Bool = false) {
            self.list = list
            self.leadingActions = leadingActions
            self.trailingActions = trailingActions
            self.isEditing = isEditing
        }
    }
    
    enum AlertStyle: Equatable, Identifiable {
        var id: UUID { UUID() }
        case error(String)
        case destructive
    }
}
