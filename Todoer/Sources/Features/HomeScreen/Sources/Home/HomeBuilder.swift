import SwiftUI
import Application
import HomeScreenContract
import Entities
import CoordinatorContract
import AppMenuContract

public struct Home {
    public typealias MakeInvitationsView = ([Invitation]) -> AnyView
    
    @MainActor
    public struct Builder {
        
        public static func makeHome(
            dependencies: HomeScreenDependencies,
            appMenuView: @escaping AppMenu.MakeAppMenuView
        ) -> some View {
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(
                store: store,
                invitationsView: makeInvitationsView(),
                appMenuView: appMenuView
            )
        }
        
        private static func makeInvitationsView(
        ) -> MakeInvitationsView {
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
}
