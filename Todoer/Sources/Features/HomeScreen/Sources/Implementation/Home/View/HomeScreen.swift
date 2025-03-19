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
    @ObservedObject private var store: Store<Home.Reducer>
    private var invitationsView: Home.MakeInvitationsView
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var source: TDListTab = .all
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
    
    var editModeBinding: Binding<EditMode> {
        Binding(
            get: { store.state.viewModel.editMode },
            set: { store.send(.didChangeEditMode($0)) }
        )
    }

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
                    content: { listContent(geometry.size.height) },
                    actions: listActions,
                    configuration: listConfiguration,
                    searchText: $searchText,
                    isSearchFocused: $isSearchFocused,
                    activeTab: activeTabBinding
                )
                .onChange(of: isSearchFocused) {
                    store.send(.didChangeSearchFocus(isSearchFocused))
                }
            }
        }
        .environment(\.editMode, editModeBinding)
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
        .onChange(of: store.state.viewState) {
            loading.show(store.state.viewState.isLoading)
        }
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
                        }
                })
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
        }
        .padding(.trailing, -20)
    }
}

// MARK: - TDListView

extension HomeScreen {
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: Strings.Home.todosText,
            tabs: store.state.viewModel.tabs
        )
    }

    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration(listHeight),
                actions: contentActions,
                rows: Binding(
                    get: { store.state.viewModel.lists.filter(by: source.isCompleted)
                        .filter(with: searchText).map { $0.tdListRow } },
                    set: { _ in }
                ),
                isEditing: Binding(
                    get: { store.state.viewModel.editMode == .active },
                    set: { _ in }
                )
            )
        )
    }

    fileprivate func contentConfiguration(_ listHeight: CGFloat) -> TDListContent.Configuration {
        .init(
            lineLimit: 2,
            isMoveEnabled: !isSearchFocused && store.state.viewModel.editMode == .active,
            isSwipeEnabled: !store.state.viewModel.isEditing && store.state.viewModel.editMode == .inactive,
            listHeight: listHeight
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        .init(
            onSubmit: { store.send(.didTapSubmitListButton($0)) },
            onCancel: { store.send(.didTapCancelButton) },
            onTap: { store.send(.didTapList($0)) },
            onSwipe: swipeActions,
            onMove: moveList
        )
    }
    
    fileprivate var listActions: (TDListTab) -> Void {
        { action in
            switch action {
            case .add:
                source = .all
                return {
                    isSearchFocused = false
                    searchText = ""
                    store.send(.didTapAddListButton)
                }()
            case .sort:
                store.send(.didTapAutoSortLists)
            case .move:
                store.send(.didTapEditButton)
            case .all:
                guard source != action else { return }
                source = .all
                store.send(.didChangeEditMode(.inactive))
            case .done:
                guard source != action else { return }
                source = .done
                store.send(.didChangeEditMode(.inactive))
            case .todo:
                guard source != action else { return }
                source = .todo
                store.send(.didChangeEditMode(.inactive))
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
            }
        }
    }

    fileprivate func moveList(fromOffset: IndexSet, toOffset: Int) {
        store.send(.didMoveList(fromOffset, toOffset, source.isCompleted))
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
        let viewModel = Home.Reducer.ViewModel()
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
