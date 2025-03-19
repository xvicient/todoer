import AppMenuContract
import Common
import CoordinatorContract
import CoordinatorMocks
import Entities
import HomeScreenContract
import Strings
import SwiftUI
import ThemeComponents
import xRedux
import Coordinator

// MARK: - HomeScreen

struct HomeScreen: View {
    
    @EnvironmentObject var loading: TDLoadingModel
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject private var store: Store<Home.Reducer>
    private var invitationsView: Home.MakeInvitationsView

    init(
        store: Store<Home.Reducer>,
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView
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
        .onChange(of: store.state.viewState) {
            loading.show(store.state.isLoading)
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

    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> TDListContent {
        TDListContent(
            configuration: contentConfiguration(listHeight),
            actions: contentActions,
            rows: $store.rows,
            editMode: $store.editMode
        )
    }

    fileprivate func contentConfiguration(_ listHeight: CGFloat) -> TDListContent.Configuration {
        .init(
            lineLimit: 2,
            isMoveEnabled: !store.isSearchFocused && store.state.editMode.isEditing,
            isSwipeEnabled: !store.state.isEditing && store.editMode.isEditing,
            listHeight: listHeight
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        .init(
            onSubmit: { store.send(.didTapSubmitListButton($0)) },
            onCancel: { store.send(.didTapCancelButton) },
            onTap: { store.send(.didTapList($0)) },
            onSwipe: swipeActions,
            onMove: { store.send(.didMoveList($0, $1)) }
        )
    }
    
    fileprivate var swipeActions: (UUID, TDSwipeAction) -> Void {
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

// MARK: - ListRow to TDRow

extension Home.Reducer.WrappedUserList {
    public var tdListRow: TDListRow {
        TDListRow(
            id: list.id,
            name: list.name,
            image: list.done ? Image.largecircleFillCircle : Image.circle,
            strikethrough: list.done,
            leadingActions: leadingActions,
            trailingActions: trailingActions,
            isEditing: isEditing
        )
    }
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: HomeScreenDependencies {
        let coordinator: CoordinatorApi
    }

    static var previews: some View {
        let reducer = Home.Reducer(dependencies: Dependencies(coordinator: CoordinatorMock()))
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
