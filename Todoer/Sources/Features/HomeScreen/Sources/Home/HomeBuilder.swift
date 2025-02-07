import SwiftUI
import Application
import HomeScreenContract
import Entities
import CoordinatorContract
import AppMenuContract

/// Namespace for home screen related types
public struct Home {
    /// Type alias for a function that creates an invitations view
    public typealias MakeInvitationsView = ([Invitation]) -> AnyView
    
    /// Builder responsible for creating the home screen and its dependencies
    @MainActor
    public struct Builder {
        /// Creates and configures the home screen
        /// - Parameter dependencies: Dependencies required by the home screen
        /// - Returns: A configured home screen view
        public static func makeHome(
            dependencies: HomeScreenDependencies
        ) -> some View {
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(
                store: store,
                invitationsView: makeInvitationsView()
            )
        }
        
        /// Creates a view builder for the invitations section
        /// - Returns: A function that creates an invitations view from an array of invitations
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
