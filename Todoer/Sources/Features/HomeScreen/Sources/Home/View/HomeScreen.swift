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

/// A view that displays the user's todo lists and provides functionality to manage them
struct HomeScreen: View {
    /// Store that manages the home screen state and actions
    @ObservedObject private var store: Store<Home.Reducer>
    /// Text used for searching lists
    @State private var searchText = ""
    /// Flag indicating if the search field is focused
    @State private var isSearchFocused = false
    /// View builder for displaying invitations
    private var invitationsView: Home.MakeInvitationsView
    
    /// Flag indicating if the screen is in editing mode
    private var isEditing: Bool {
        store.state.viewState == .addingList ||
        store.state.viewState == .editingList
    }
    
    /// Filtered lists based on search text
    private var filteredLists: [Home.Reducer.WrappedUserList] {
        searchText.isEmpty ? store.state.viewModel.lists : store.state.viewModel.lists.filter {
            $0.list.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

    /// Initializes the home screen
    /// - Parameters:
    ///   - store: Store that manages the screen's state
    ///   - invitationsView: View builder for displaying invitations
    init(
        store: Store<Home.Reducer>,
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView
    ) {
        self.store = store
        self.invitationsView = invitationsView
    }

    /// The body of the view that constructs the home screen interface
    var body: some View {
        ZStack {
            TDList(
                sections: sections,
                isEditing: isEditing,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            loadingView
        }
        .onAppear {
            store.send(.onViewAppear)
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
    /// Creates the sections of the list, including invitations if present
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

    /// Creates the content of the list section
    @ViewBuilder
    func listContent() -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration,
                actions: contentActions
            )
        )
    }

    /// Loading indicator view
    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }
}

// MARK: - List configurations

private extension HomeScreen {
    /// Configuration for the list section
    var sectionConfiguration: TDListSection.Configuration {
        .init(
            title: Strings.Home.todosText,
            addButtonTitle: Strings.Home.newTodoButtonTitle,
            isDisabled: store.state.viewModel.lists.isEmpty,
            isEditMode: isEditing
        )
    }
    
    /// Actions available in the list section
    var sectionActions: TDListSection.Actions {
        .init(
            onAddRow: { store.send(.didTapAddRowButton) },
            onSortRows: { store.send(.didTapAutoSortLists) }
        )
    }
    
    /// Configuration for the list content
    var contentConfiguration: TDListContent.Configuration {
        .init(
            rows: filteredLists.map { $0.tdListRow },
            isMoveAllowed: !isSearchFocused && !isEditing
        )
    }
    
    /// Actions available in the list content
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
    /// Handles swipe actions on list items
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

    /// Handles reordering of list items
    fileprivate func moveList(fromOffset: IndexSet, toOffset: Int) {
        guard !isSearchFocused else { return }
        store.send(.didSortLists(fromOffset, toOffset))
    }
}

// MARK: - ListRow to TDRow

extension Home.Reducer.WrappedUserList {
    /// Converts a wrapped user list to a TDListRow for display
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

/// Preview provider for the home screen
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
