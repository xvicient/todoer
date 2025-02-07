import AppMenuContract

extension AppMenu.Reducer {

    // MARK: - ViewModel

    /// View model for the app menu that holds UI-related data
    /// This structure is designed to run on the main actor to ensure UI updates are thread-safe
    @MainActor
    struct ViewModel {
        /// URL string of the user's profile photo
        var photoUrl = ""
    }
}
