import SwiftUI
import CoordinatorMocks
import Application
import CoordinatorContract
import ThemeComponents
import Entities
import Common
import HomeScreenContract
import AppMenuContract

// MARK: - HomeScreen

struct HomeScreen: View {
	@ObservedObject private var store: Store<Home.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    private var invitationsView: Home.MakeInvitationsView
    private var appMenuView: AppMenu.MakeAppMenuView
    
    private var isEditing: Bool {
        store.state.viewState == .addingList ||
        store.state.viewState == .editingList
    }
    
    private var filteredLists: [Home.Reducer.WrappedUserList] {
        searchText.isEmpty ? store.state.viewModel.lists : store.state.viewModel.lists.filter {
            $0.list.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

	init(
        store: Store<Home.Reducer>,
        @ViewBuilder invitationsView: @escaping Home.MakeInvitationsView,
        @ViewBuilder appMenuView: @escaping AppMenu.MakeAppMenuView
    ) {
		self.store = store
        self.invitationsView = invitationsView
        self.appMenuView = appMenuView
	}

	var body: some View {
		ZStack {
			contentView
			loadingView
		}
		.onAppear {
			store.send(.onViewAppear)
		}
		.disabled(
			store.state.viewState == .loading
		)
		.navigationBarItems(
			leading: appMenuView()
		)
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
	}
}

// MARK: - ViewBuilders

extension HomeScreen {
    
    private var listSectionConfiguration: TDListSection.Configuration {
        .init(
            title: Home.Strings.todos,
            addButtonTitle: Home.Strings.newRowButtonTitle,
            isDisabled: store.state.viewModel.lists.isEmpty,
            isEditMode: isEditing
        )
    }
    
    private var listSectionActions: TDListSection.Actions {
        .init(
            onAddRow: { store.send(.didTapAddRowButton) },
            onSortRows: { store.send(.didTapAutoSortLists) }
        )
    }
    
	@ViewBuilder
	fileprivate var contentView: some View {
        List {
            invitationsSection
            TDListSection(
                content: listContent,
                configuration: listSectionConfiguration,
                actions: listSectionActions
            )
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .if(!isEditing) { content in
            withAnimation {
                content.searchable(
                    text: $searchText,
                    isPresented: $isSearchFocused,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
            }
        }
	}

	@ViewBuilder
	fileprivate var invitationsSection: some View {
		if !store.state.viewModel.invitations.isEmpty {
            invitationsView(store.state.viewModel.invitations)
		}
	}
    
    private var listContentConfiguration: TDListContent.Configuration {
        .init(
            rows: filteredLists.map { $0.tdListRow },
            isMoveAllowed: !isSearchFocused
        )
    }
    
    private var listContentActions: TDListContent.Actions {
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
    fileprivate func listContent() -> AnyView {
        AnyView(
            TDListContent(
                configuration: listContentConfiguration,
                actions: listContentActions
            )
        )
    }

	@ViewBuilder
	fileprivate var loadingView: some View {
		if store.state.viewState == .loading {
			ProgressView()
		}
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
        guard !isSearchFocused else { return }
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
            dependencies: Dependencies(coordinator: CoordinatorMock()),
            appMenuView: { AnyView(EmptyView()) }
        )
    }
}
