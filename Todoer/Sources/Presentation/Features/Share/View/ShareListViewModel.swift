import Foundation

extension ShareList.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var users = [User]()
	}
}
