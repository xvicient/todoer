import SwiftUI
import Application
import CoordinatorContract
import ThemeComponents

// MARK: - HomeScreen

struct HomeScreen: View {
	@ObservedObject private var store: Store<Home.Reducer>

	init(store: Store<Home.Reducer>) {
		self.store = store
	}

	var body: some View {
		ZStack {
			lists
			newRowButton
			loadingView
		}
		.onAppear {
			store.send(.onViewAppear)
		}
		.disabled(
			store.state.viewState == .loading
		)
		.navigationBarItems(
			leading: navigationBarLeadingItems,
			trailing: navigationBarTrailingItems
		)
		.alert(item: alertBinding) {
			alert(for: $0)
		}
	}
}

// MARK: - ViewBuilders

extension HomeScreen {
	@ViewBuilder
	fileprivate var navigationBarTrailingItems: some View {
		TDOptionsMenuView(onSort: { store.send(.didTapAutoSortLists) })
	}

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
	fileprivate var lists: some View {
		ScrollViewReader { scrollView in
			List {
				invitationsSection
				listsSection
			}
			.listRowStyle(
				onChangeOf: store.state.viewState == .addingList,
				count: store.state.viewModel.lists.count,
				scrollView: scrollView
			)
		}
	}

	@ViewBuilder
	fileprivate var invitationsSection: some View {
		if !store.state.viewModel.invitations.isEmpty {
			HomeInvitationsView(
				invitations: store.state.viewModel.invitations,
				onAccept: { store.send(.didTapAcceptInvitation($0, $1)) },
				onDecline: { store.send(.didTapDeclineInvitation($0)) }
			)
		}
	}

	@ViewBuilder
	fileprivate var listsSection: some View {
		Section(header: Text(Constants.Text.todos).listRowHeaderStyle()) {
			ForEach(
				Array(store.state.viewModel.lists.enumerated()),
				id: \.element.id
			) { index, row in
				if row.isEditing {
					TDNewRowView(
						row: row.tdRow,
						onSubmit: { store.send(.didTapSubmitListButton($0)) },
						onUpdate: { store.send(.didTapUpdateListButton(index, $0)) },
						onCancelAdd: { store.send(.didTapCancelAddListButton) },
						onCancelEdit: { store.send(.didTapCancelEditListButton(index)) }
					)
					.id(index)
				}
				else {
					TDRowView(
						row: row.tdRow,
						onTap: { store.send(.didTapList(index)) },
						onSwipe: { swipeActions(index, $0) }
					)
					.id(index)
				}
			}.onMove(perform: moveList)
		}
	}

	@ViewBuilder
	fileprivate var newRowButton: some View {
		if store.state.viewState != .addingList && store.state.viewState != .editingList {
			TDNewRowButton { store.send(.didTapAddRowButton) }
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
	fileprivate var swipeActions: (Int, TDSwipeAction) -> Void {
		{ index, option in
			switch option {
			case .done, .undone:
				store.send(.didTapToggleListButton(index))
			case .delete:
				store.send(.didTapDeleteListButton(index))
			case .share:
				store.send(.didTapShareListButton(index))
			case .edit:
				store.send(.didTapEditListButton(index))
			}
		}
	}

	fileprivate func moveList(fromOffset: IndexSet, toOffset: Int) {
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
		}
	}
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home.Builder.makeHome(coordinator: CoordinatorMock())
    }
    
    private struct CoordinatorMock: CoordinatorApi {
        func loggOut() {}
        func loggIn() {}
        func push(_ page: Page) {}
        func present(sheet: Sheet) {}
        func present(fullScreenCover: FullScreenCover) {}
        func pop() {}
        func popToRoot() {}
        func dismissSheet() {}
    }
}
