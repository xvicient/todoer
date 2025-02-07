import SwiftUI
import Entities

extension Invitations.Reducer {

	// MARK: - ViewModel

	@MainActor
	struct ViewModel {
		var invitations = [Invitation]()
	}
}
