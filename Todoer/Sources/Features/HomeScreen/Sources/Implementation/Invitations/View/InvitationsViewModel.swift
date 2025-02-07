import Entities
import SwiftUI

extension Invitations.Reducer {

    // MARK: - ViewModel

    @MainActor
    struct ViewModel {
        var invitations = [Invitation]()
    }
}
