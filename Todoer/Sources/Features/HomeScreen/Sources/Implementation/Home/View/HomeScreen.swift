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
    
    @Bindable private var store: Store<HomeReducer>
    private var invitationsView: MakeHomeInvitationsView

    init(
        store: Store<HomeReducer>,
        @ViewBuilder invitationsView: @escaping MakeHomeInvitationsView
    ) {
        self.store = store
        self.invitationsView = invitationsView
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                TDListView(
                    configuration: listConfiguration
                ) {
                    listContent(geometry.size.height)
                }
            }
        }
        .environment(\.editMode, $store.editMode)
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
        .onAppear {
            store.send(.onViewAppear)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                store.send(.onSceneActive)
            }
        }
        .onChange(of: store.isLoading) {
            loading.show(store.isLoading)
        }
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}

// MARK: - TDListView

extension HomeScreen {
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: Strings.Home.todosText,
            tabs: store.state.tabs,
            activeTab: $store.activeTab,
            searchText: $store.searchText,
            isSearchFocused: $store.isSearchFocused
        )
    }

    fileprivate func listContent(_ listHeight: CGFloat) -> TDListContentView {
        let configuration = TDListContentView.Configuration(
            lineLimit: 2,
            isMoveEnabled: !store.isSearchFocused && store.editMode.isEditing,
            isSwipeEnabled: !store.isUpdating,
            listHeight: listHeight
        )
        
        let actions = TDListContentView.Actions(
            onSubmit: { store.send(.didTapSubmitListButton($0, $1)) },
            onCancel: { store.send(.didTapCancelButton) },
            onTap: { store.send(.didTapList($0)) },
            onSwipe: onSwipe,
            onMove: { store.send(.didMoveList($0, $1)) }
        )
        
        return TDListContentView(
            configuration: configuration,
            actions: actions,
            rows: $store.rows,
            editMode: $store.editMode
        )
    }
    
    fileprivate var onSwipe: (UUID, TDListSwipeAction) -> Void {
        { rowId, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleListButton(rowId))
            case .delete:
                store.send(.didTapDeleteListButton(rowId))
            case .share:
                store.send(.didTapShareListButton(rowId))
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: HomeScreenDependencies {
        let coordinator: CoordinatorApi
    }

    static var previews: some View {
        let reducer = HomeReducer(dependencies: Dependencies(coordinator: CoordinatorMock()))
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
