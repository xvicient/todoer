import Foundation
import Entities

extension ShareList.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var users = [User]()
	}
}
