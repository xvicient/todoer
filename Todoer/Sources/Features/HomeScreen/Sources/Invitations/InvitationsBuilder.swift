import SwiftUI
import xRedux
import Entities

public struct Invitations {
    public struct Builder {
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
