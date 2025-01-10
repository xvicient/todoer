import Foundation
import Data

extension ShareList.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var users = [User]()
	}
}
