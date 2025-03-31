import AppMenuContract
import CoordinatorContract
import Entities
import HomeScreenContract
import SwiftUI
import xRedux

public typealias MakeHomeInvitationsView = ([Invitation]) -> AnyView

@MainActor
public struct HomeBuilder {
    
    public static func makeHome(
        dependencies: HomeScreenDependencies
    ) -> some View {
        let reducer = HomeReducer(dependencies: dependencies)
        let store = Store(initialState: .init(), reducer: reducer)
        return HomeScreen(
            store: store,
            invitationsView: makeInvitationsView()
        )
    }
    
    private static func makeInvitationsView() -> MakeHomeInvitationsView {
        {
            AnyView(
                Invitations.Builder.makeInvitations(
                    invitations: $0
                )
                .id(UUID())
            )
        }
    }
}
