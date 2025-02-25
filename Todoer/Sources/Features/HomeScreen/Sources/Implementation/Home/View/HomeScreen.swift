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

// MARK: - HomeScreen

struct HomeScreen: View {
    @ObservedObject private var store: Store<Home.Reducer>
    @Environment(\.scenePhase) private var scenePhase
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    private var invitationsView: Home.MakeInvitationsView
    @State private var loadingOpacity: Double = 1
    @State private var isToolbarHidden: Visibility = .hidden
    @State private var activeTab: TDListTabAction = .all
    private var isLoading: Bool {
        store.state.viewState.isLoading &&
        store.state.viewModel.lists.isEmpty
    }

    init(
        store: Store<Home.Reducer>,
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView
    ) {
        self.store = store
        self.invitationsView = invitationsView
    }

    var body: some View {
        ZStack {
            TDListView(
                content: listContent,
                actions: listActions,
                configuration: listConfiguration,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            .zIndex(0)
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                if store.state.viewState == .addingList {
                    store.send(.didTapCancelAddListButton)
                }
                else if case let .editingList(uid) = store.state.viewState {
                    store.send(.didTapCancelEditListButton(uid))
                }
            }
            loadingView
            .zIndex(1)
        }
        .toolbar(isToolbarHidden, for: .navigationBar)
        .onAppear {
            store.send(.onViewAppear)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                store.send(.onSceneActive)
            }
        }
        .disabled(
            store.state.viewState.isLoading
        )
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}

// MARK: - ViewBuilders

extension HomeScreen {
    fileprivate var tabActions: [TDListTabActionItem] {
        TDListTabAction.allCases
            .sorted { $0.rawValue < $1.rawValue }
            .map { tab in
                let sortEnabled = store.state.viewModel.lists.filter { !$0.isEditing }.count > 1
                return TDListTabActionItem(tab: tab, isEnabled: tab == .sort ? sortEnabled : true )
            }
        
    }
    
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: Strings.Home.todosText,
            tabActions: tabActions
        )
    }

    @ViewBuilder
    fileprivate func listContent() -> AnyView {
        AnyView(
            Group {
                if activeTab == .invitations {
                    invitationsView(store.state.viewModel.invitations)
                } else {
                    TDListContent(
                        configuration: contentConfiguration,
                        actions: contentActions,
                        rows: store.state.viewModel.lists.filter(with: searchText).map { $0.tdListRow }
                    )
                }
            }
        )
    }

    fileprivate var contentConfiguration: TDListContent.Configuration {
        .init(
            lineLimit: 2,
            isMoveEnabled: !isSearchFocused && !store.state.viewState.isEditing,
            isSwipeEnabled: !store.state.viewState.isEditing
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        .init(
            onSubmit: { store.send(.didTapSubmitListButton($0)) },
            onUpdate: { store.send(.didTapUpdateListButton($0, $1)) },
            onCancelAdd: { store.send(.didTapCancelAddListButton) },
            onCancelEdit: { store.send(.didTapCancelEditListButton($0)) },
            onTap: { store.send(.didTapList($0)) },
            onSwipe: swipeActions,
            onMove: moveList
        )
    }
    
    @ViewBuilder
    fileprivate var loadingView: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Image.todoer
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 35)
                .scaleEffect(loadingOpacity == 1 ? 1 : 0.5)
                .animation(.interactiveSpring(), value: loadingOpacity)
        }
        .opacity(loadingOpacity)
        .animation(.spring(duration: 0.3), value: loadingOpacity)
        .onChange(of: store.state.viewState.isLoading) {
            if !store.state.viewState.isLoading {
                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                    loadingOpacity = 0
                }
                isToolbarHidden = .visible
            } else if store.state.viewModel.lists.isEmpty {
                withAnimation(.easeIn(duration: 0.2)) {
                    loadingOpacity = 1
                }
                isToolbarHidden = .hidden
            }
        }
    }
}

// MARK: - Private

extension HomeScreen {
    fileprivate var listActions: (TDListTabAction) -> Void {
        { action in
            activeTab = action
            switch action {
            case .add:
                {
                    isSearchFocused = false
                    searchText = ""
                    store.send(.didTapAddRowButton)
                }()
            case .sort:
                store.send(.didTapAutoSortLists)
            case .all:
                break
            case .sharing:
                break
            case .invitations:
                break
            }
        }
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
            case .edit:
                store.send(.didTapEditListButton(rowId))
            }
        }
    }

    fileprivate func moveList(fromOffset: IndexSet, toOffset: Int) {
        guard !isSearchFocused, !store.state.viewState.isEditing else { return }
        store.send(.didSortLists(fromOffset, toOffset))
    }
}

// MARK: - ListRow to TDRow

extension Home.Reducer.WrappedUserList {
    fileprivate var tdListRow: TDListRow {
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
        var viewModel = Home.Reducer.ViewModel()
        let list = UserList.empty
        viewModel.lists = [
            Home.Reducer.WrappedUserList(
                id: list.id,
                list: list,
                isEditing: false
            )]
        let reducer = Home.Reducer(dependencies: Dependencies(coordinator: CoordinatorMock()))
        let store = Store(initialState: .init(viewModel: viewModel), reducer: reducer)
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
