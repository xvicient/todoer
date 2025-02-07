import SwiftUI
import Entities

extension Invitations.Reducer {

    // MARK: - ViewModel

    /// View model that holds the UI-related data for invitations
    @MainActor
    struct ViewModel {
        /// Array of pending invitations to be displayed
        var invitations = [Invitation]()
    }
}
