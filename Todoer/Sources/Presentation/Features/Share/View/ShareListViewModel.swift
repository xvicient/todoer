import Foundation
import Common

extension ShareList.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var users = [User]()
	}
}
