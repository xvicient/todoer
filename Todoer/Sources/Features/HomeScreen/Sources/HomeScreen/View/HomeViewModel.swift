import Foundation
import Data
import ThemeComponents

extension Home.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var lists = [ListRow]()
		var invitations = [Invitation]()
		var photoUrl = ""
	}

    struct ListRow: Identifiable, Sendable {
		let id = UUID()
		var list: UserList
		let leadingActions: [TDSwipeAction]
		let trailingActions: [TDSwipeAction]
		var isEditing: Bool

		init(
			list: UserList,
			leadingActions: [TDSwipeAction] = [],
			trailingActions: [TDSwipeAction] = [],
			isEditing: Bool = false
		) {
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
