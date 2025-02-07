import SwiftUI
import Application
import Entities

/// Namespace for the invitations feature components
public struct Invitations {
    /// Builder responsible for creating the invitations view and its dependencies
    public struct Builder {
        /// Creates a new invitations view with the provided invitations
        /// - Parameter invitations: Array of invitations to display
        /// - Returns: A view displaying the invitations
        @MainActor
        public static func makeInvitations(
            invitations: [Invitation]
        ) -> some View {
            let reducer = Reducer(
                invitations: invitations,
                useCase: UseCase()
            )
            let store = Store(initialState: .init(), reducer: reducer)
            return InvitationsView(store: store)
        }
    }
}
