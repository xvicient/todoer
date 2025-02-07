import Foundation
import Entities
import ThemeComponents

extension Home.Reducer {
    // MARK: - ViewModel

    /// View model for the home screen that holds UI-related data
    /// This structure is designed to run on the main actor to ensure UI updates are thread-safe
    @MainActor
    struct ViewModel {
        /// Array of wrapped user lists to display
        var lists = [WrappedUserList]()
        /// Array of pending invitations
        var invitations = [Invitation]()
        /// URL string of the user's profile photo
        var photoUrl = ""
    }

    /// A wrapper around UserList that includes UI-specific properties
    struct WrappedUserList: Identifiable, Sendable {
        /// Unique identifier for the list
        let id: UUID
        /// The underlying user list data
        var list: UserList
        /// Available leading swipe actions for the list
        let leadingActions: [TDSwipeAction]
        /// Available trailing swipe actions for the list
        let trailingActions: [TDSwipeAction]
        /// Flag indicating if the list is being edited
        var isEditing: Bool

        /// Initializes a wrapped user list
        /// - Parameters:
        ///   - id: Unique identifier for the list
        ///   - list: The underlying user list data
        ///   - leadingActions: Available leading swipe actions
        ///   - trailingActions: Available trailing swipe actions
        ///   - isEditing: Whether the list is being edited
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

/// Extension to provide helper methods for arrays of wrapped user lists
extension Array where Element == Home.Reducer.WrappedUserList {
    /// Finds the index of a list with the specified ID
    /// - Parameter id: The ID to search for
    /// - Returns: The index of the list if found, nil otherwise
    func index(for id: UUID) -> Int? {
        self.firstIndex(where: { $0.id == id })
    }
}
