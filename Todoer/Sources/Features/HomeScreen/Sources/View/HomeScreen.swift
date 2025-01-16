import SwiftUI
import Application
import CoordinatorContract
import ThemeComponents
import Mocks
import Common
import HomeScreenContract

// MARK: - HomeScreen

struct HomeScreen: View {
	@ObservedObject private var store: Store<Home.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    private var isEditing: Bool {
        store.state.viewState == .addingList ||
        store.state.viewState == .editingList
    }
    
    private var filteredLists: [Home.Reducer.ListRow] {
        searchText.isEmpty ? store.state.viewModel.lists : store.state.viewModel.lists.filter {
            $0.list.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

	init(store: Store<Home.Reducer>) {
		self.store = store
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
			leading: navigationBarLeadingItems
		)
		.alert(item: alertBinding) {
			alert(for: $0)
		}
	}
}

// MARK: - ViewBuilders

extension HomeScreen {
	@ViewBuilder
	fileprivate var navigationBarLeadingItems: some View {
		HomeAccountMenuView(
			profilePhotoUrl: store.state.viewModel.photoUrl,
			onAboutTap: { store.send(.didTapAboutButton) },
			onDelteAccountTap: { store.send(.didTapDeleteAccountButton) },
			onSignoupTap: { store.send(.didTapSignoutButton) },
			onProfilePhotoAppear: { store.send(.onProfilePhotoAppear) }
		)
	}

	@ViewBuilder
	fileprivate var contentView: some View {
        List {
            invitations
            lists
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
	fileprivate var invitations: some View {
		if !store.state.viewModel.invitations.isEmpty {
			HomeInvitationsView(
				invitations: store.state.viewModel.invitations,
				onAccept: { store.send(.didTapAcceptInvitation($0, $1)) },
				onDecline: { store.send(.didTapDeclineInvitation($0)) }
			)
		}
	}

	@ViewBuilder
    fileprivate var lists: some View {
        Section(header: Text(Constants.Text.todos).listRowHeaderStyle()) {
            listsHeader
            listsContent
        }
	}
    
    @ViewBuilder
    fileprivate var listsHeader: some View {
        HStack {
            TDActionButton(
                title: Constants.Text.newRowButtonTitle,
                icon: Image.plusCircleFill
            ) {
                store.send(.didTapAddRowButton)
            }
            TDActionButton(
                title: Constants.Text.sortButtonTitle,
                icon: Image.arrowUpArrowDownCircleFill
            ) {
                store.send(.didTapAutoSortLists)
            }
        }
        .disabled(
            isEditing ||
            isSearchFocused
        )
        .padding(.bottom, 12)
    }

    @ViewBuilder
    fileprivate var listsContent: some View {
        ForEach(
            Array(filteredLists.enumerated()),
            id: \.element.id
        ) { index, row in
            if row.isEditing {
                TDNewRowView(
                    row: row.tdRow,
                    onSubmit: { store.send(.didTapSubmitListButton($0)) },
                    onUpdate: { store.send(.didTapUpdateListButton(row.id, $0)) },
                    onCancelAdd: { store.send(.didTapCancelAddListButton) },
                    onCancelEdit: { store.send(.didTapCancelEditListButton(row.id)) }
                )
                .id(index)
            }
            else {
                TDRowView(
                    row: row.tdRow,
                    onTap: { store.send(.didTapList(row.id)) },
                    onSwipe: { swipeActions(row.id, $0) }
                )
                .id(index)
            }
        }
        .if(!isSearchFocused) {
            $0.onMove(perform: moveList)
        }
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

	fileprivate var alertBinding: Binding<Home.Reducer.AlertStyle?> {
		Binding(
			get: {
				guard case .alert(let data) = store.state.viewState else {
					return nil
				}
				return data
			},
			set: { _ in }
		)
	}

	fileprivate func alert(for style: Home.Reducer.AlertStyle) -> Alert {
		switch style {
		case let .error(message):
			Alert(
				title: Text(Constants.Text.errorTitle),
				message: Text(message),
				dismissButton: .default(Text(Constants.Text.okButton)) {
					store.send(.didTapDismissError)
				}
			)
		case .destructive:
			Alert(
				title: Text(""),
				message: Text(Constants.Text.deleteAccountConfirmation),
				primaryButton: .destructive(Text(Constants.Text.deleteButton)) {
					store.send(.didTapConfirmDeleteAccount)
				},
				secondaryButton: .default(Text(Constants.Text.cancelButton)) {
					store.send(.didTapDismissDeleteAccount)
				}
			)
		}
	}
}

// MARK: - ListRow to TDRow

extension Home.Reducer.ListRow {
	fileprivate var tdRow: TDRow {
		TDRow(
			name: list.name,
			image: list.done ? Image.largecircleFillCircle : Image.circle,
			strikethrough: list.done,
			leadingActions: leadingActions,
			trailingActions: trailingActions,
			isEditing: isEditing
		)
	}
}

// MARK: - Constants

extension HomeScreen {
	fileprivate struct Constants {
		struct Text {
			static let todos = "To-dos"
			static let deleteAccountConfirmation =
				"This action will delete your account and data. Are you sure?"
			static let errorTitle = "Error"
			static let okButton = "Ok"
			static let deleteButton = "Delete"
			static let cancelButton = "Cancel"
            static let newRowButtonTitle = "New To-do"
            static let sortButtonTitle = "Sort"
		}
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
