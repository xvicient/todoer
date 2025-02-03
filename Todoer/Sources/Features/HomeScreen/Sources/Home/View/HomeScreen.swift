import SwiftUI
import CoordinatorMocks
import Application
import CoordinatorContract
import ThemeComponents
import Entities
import Common
import HomeScreenContract
import AppMenuContract
import Strings

// MARK: - HomeScreen

struct HomeScreen: View {
    @ObservedObject private var store: Store<Home.Reducer>
    @Environment(\.scenePhase) private var scenePhase
    @State private var searchText = ""
    @State private var isSearchFocused = false
    private var invitationsView: Home.MakeInvitationsView

    init(
        store: Store<Home.Reducer>,
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView
    ) {
        self.store = store
        self.invitationsView = invitationsView
    }

    var body: some View {
        ZStack {
            TDList(
                sections: sections,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                if store.state.viewState == .addingList {
                    store.send(.didTapCancelAddListButton)
                } else if case let .editingList(uid) = store.state.viewState {
                    store.send(.didTapCancelEditListButton(uid))
                }
            }
            loadingView
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
            store.state.viewState == .loading
        )
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
    }
}

// MARK: - ViewBuilders

private extension HomeScreen {
    
    @ViewBuilder
    func sections() -> AnyView {
        AnyView(
            Group{
                if !store.state.viewModel.invitations.isEmpty {
                    invitationsView(store.state.viewModel.invitations)
                }
                TDListSection(
                    content: listContent,
                    configuration: sectionConfiguration,
                    actions: sectionActions
                )
            }
        )
    }

    @ViewBuilder
    func listContent() -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration,
                actions: contentActions
            )
        )
    }

    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }
}

// MARK: - List comfigurations

private extension HomeScreen {
    
    var sectionConfiguration: TDListSection.Configuration {
        .init(
            title: Strings.Home.todosText,
            addButtonTitle: Strings.Home.newTodoButtonTitle,
            isSortEnabled: store.state.viewModel.lists.filter { !$0.isEditing }.count > 1
        )
    }
    
    var sectionActions: TDListSection.Actions {
        .init(
            onAddRow: {
                isSearchFocused = false
                searchText = ""
                store.send(.didTapAddRowButton)
            },
            onSortRows: { store.send(.didTapAutoSortLists) }
        )
    }
    
    var contentConfiguration: TDListContent.Configuration {
        .init(
            rows: store.state.viewModel.lists.filter(with: searchText).map { $0.tdListRow },
            lineLimit: 2,
            isMoveEnabled: !isSearchFocused && !store.state.viewState.isEditing,
            isSwipeEnabled: !store.state.viewState.isEditing
        )
    }
    
    var contentActions: TDListContent.Actions {
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
}

// MARK: - Private

extension HomeScreen {
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
        Home.Builder.makeHome(
            dependencies: Dependencies(coordinator: CoordinatorMock())
        )
    }
}
