import Foundation
import Entities

extension ShareList.Reducer {

	// MARK: - ViewModel

    /// View model containing the data needed for the ShareList screen
    @MainActor
    struct ViewModel {
        /// List of users that can be shared with
        var users = [User]()
        /// Name of the current user
        var selfName: String?
    }
}
