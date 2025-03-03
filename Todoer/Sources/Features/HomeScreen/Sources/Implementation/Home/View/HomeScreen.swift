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
    private enum Source {
        case allLists
        case sharingLists
        
        var activeTab: TDListTab {
            switch self {
            case .allLists:
                .all
            case .sharingLists:
                .sharing
            }
        }
    }
    
    @ObservedObject private var store: Store<Home.Reducer>
    private var invitationsView: Home.MakeInvitationsView
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var loadingOpacity: Double = 1
    @State private var isToolbarHidden: Visibility = .hidden
    @State private var source: Source = .allLists
    @State var isShowingInvitations: Bool = false
    @State private var sheetHeight: CGFloat = 0
    
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    private var activeTabBinding: Binding<TDListTab> {
        Binding(
            get: { source.activeTab },
            set: { _ in }
        )
    }

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
                isSearchFocused: $isSearchFocused,
                activeTab: activeTabBinding
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
        .toolbar {
            if !store.state.viewModel.invitations.isEmpty {
                ToolbarItem(placement: .automatic) {
                    invitationsToolbarItem
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
    
    @ViewBuilder
    fileprivate var invitationsToolbarItem: some View {
        Button {
            isShowingInvitations = true
        } label: {
            Image.squareArrowDownFill
                .foregroundStyle(.black)
                .font(.system(size: 14))
                .padding(5)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                .overlay(
                    Text("\(store.state.viewModel.invitations.count)")
                        .font(.caption2).bold()
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(Color.red))
                        .offset(x: 5, y: -3),
                    alignment: .topTrailing
                )
        }
        .sheet(isPresented: $isShowingInvitations, onDismiss: {
            isShowingInvitations = false
        }) {
            invitationsView(store.state.viewModel.invitations)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            sheetHeight = geometry.size.height
                            print(geometry.size.height)
                        }
                })
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
        }
        .padding(.trailing, -20)
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

// MARK: - TDListView

extension HomeScreen {
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: Strings.Home.todosText,
            tabs: TDListTab.allCases
                .removingSort(if: store.state.viewModel.lists.filter { !$0.isEditing }.count < 2)
        )
    }

    @ViewBuilder
    fileprivate func listContent() -> AnyView {
        AnyView(
            Group {
                switch source {
                case .allLists:
                    TDListContent(
                        configuration: contentConfiguration,
                        actions: contentActions,
                        rows: store.state.viewModel.lists.filter(with: searchText).map { $0.tdListRow }
                    )
                case .sharingLists:
                    let rows = store.state.viewModel.lists
                        .filter { list in
                            !list.list.uid.filter { $0 != store.state.viewModel.userUid }.isEmpty
                        }
                        .filter(with: searchText).map { $0.tdListRow }
                    TDListContent(
                        configuration: contentConfiguration,
                        actions: contentActions,
                        rows: rows
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
    
    fileprivate var listActions: (TDListTab) -> Void {
        { action in
            switch action {
            case .add:
                source = .allLists
                return {
                    isSearchFocused = false
                    searchText = ""
                    store.send(.didTapAddRowButton)
                }()
            case .sort:
                store.send(.didTapAutoSortLists)
            case .all:
                source = .allLists
            case .sharing:
                source = .sharingLists
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
