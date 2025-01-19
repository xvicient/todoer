import SwiftUI
import Application
import HomeScreenContract
import Entities
import CoordinatorContract

public struct Home {
    public typealias MakeInvitationsView = ([Invitation]) -> AnyView
    public typealias MakeAppMenuView = () -> AnyView
    
    @MainActor
    public struct Builder {
        
        public static func makeHome(
            dependencies: HomeScreenDependencies
        ) -> some View {
            let reducer = Reducer(dependencies: dependencies)
            let store = Store(initialState: .init(), reducer: reducer)
            return HomeScreen(
                store: store,
                invitationsView: makeInvitationsView(),
                appMenuView: makeAppMenuView(coordinator: dependencies.coordinator)
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
        
        private static func makeAppMenuView(
            coordinator: CoordinatorApi
        ) -> MakeAppMenuView {
            {
                struct Dependencies: AppMenuDependencies {
                    var coordinator: CoordinatorApi
                }
                
                return AnyView(
                    AppMenu.Builder.makeAppMenu(
                        dependencies: Dependencies(coordinator: coordinator)
                    )
                    .id(UUID())
                )
            }
        }
    }
}
