import Common
import CoordinatorContract
import CoordinatorMocks
import Entities
import HomeScreenContract
import Strings
import SwiftUI
import ThemeComponents
import xRedux

// MARK: - HomeScreen

struct HomeScreen: View {
    
    @EnvironmentObject var loading: TDLoadingModel
    @Environment(\.scenePhase) private var scenePhase
    
    @Bindable private var store: Store<HomeReducer<HomeUseCase>>
    private var invitationsView: MakeHomeInvitationsView

    init(
        store: Store<HomeReducer<HomeUseCase>>,
        @ViewBuilder invitationsView: @escaping MakeHomeInvitationsView
    ) {
        self.store = store
        self.invitationsView = invitationsView
    }

    var body: some View {
        TDListView(
            store: store,
            title: Strings.Home.todosText,
            onAppear: { store.send(.onViewAppear) },
            onTap: { store.send(.didTapList($0)) },
            onShare: { store.send(.didTapShareListButton($0)) }
        )
        .toolbar {
            if !store.state.invitations.isEmpty {
                ToolbarItem(placement: .automatic) {
                    InvitationsToolbarView(
                        invitationsView: invitationsView,
                        invitations: store.state.invitations
                    )
                }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                store.send(.onSceneActive)
            }
        }
        .onChange(of: store.isLoading) {
            loading.show(store.isLoading)
        }
    }
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: HomeScreenDependencies {
        let coordinator: CoordinatorApi?
    }

    static var previews: some View {
        let reducer = HomeReducer(dependencies: Dependencies(coordinator: CoordinatorMock()), useCase: HomeUseCase())
        let store = Store(initialState: .init(), reducer: reducer)
        return HomeScreen(
            store: store,
            invitationsView: {
                AnyView(
                    Invitations.Builder.makeInvitations(
                        invitations: $0
                    )
                    .id(UUID())
                )
            }
        )
    }
}
