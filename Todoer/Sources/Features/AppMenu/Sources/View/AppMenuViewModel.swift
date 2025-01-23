import AppMenuContract

extension AppMenu.Reducer {

    /// View model for the app menu that holds UI-related data
    /// This structure is designed to run on the main actor to ensure UI updates are thread-safe
	@MainActor
	struct ViewModel {
		var photoUrl = ""
	}
}
