import Foundation
import Entities
import ThemeComponents
import Common

extension Home.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var lists = [WrappedUserList]()
		var invitations = [Invitation]()
		var photoUrl = ""
	}

    struct WrappedUserList: Identifiable, Sendable {
        let id: UUID
		var list: UserList
		let leadingActions: [TDSwipeAction]
		let trailingActions: [TDSwipeAction]
		var isEditing: Bool

		init(
            id: UUID,
			list: UserList,
			leadingActions: [TDSwipeAction] = [],
			trailingActions: [TDSwipeAction] = [],
			isEditing: Bool = false
		) {
            self.id = id
			self.list = list
			self.leadingActions = leadingActions
			self.trailingActions = trailingActions
			self.isEditing = isEditing
		}
	}
}

extension Array where Element == Home.Reducer.WrappedUserList {
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
