import SwiftUI
import Application
import HomeScreenContract
import Entities

public struct Home {
    public typealias MakeInvitationsView = ([Invitation]) -> AnyView
    
    public struct Builder {
        @MainActor
        public static func makeHome(
            dependencies: HomeScreenDependencies
        ) -> some View {
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(store: store, invitationsView: makeInvitationsView())
        }
        
        @MainActor
        public static func makeInvitationsView(
        ) -> MakeInvitationsView {
            { invitations in
                AnyView(
                    Invitations.Builder.makeInvitations(
                        invitations: invitations
                    )
                    .id(UUID())
                )
            }
        }
    }
}
