import SwiftUI
import Entities
import Application
import ThemeComponents

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
	@ObservedObject private var store: Store<ListItems.Reducer>
	private var listName: String
    @State private var searchText = ""
    
    private var filteredItems: [ListItems.Reducer.ItemRow] {
        searchText.isEmpty ? store.state.viewModel.items : store.state.viewModel.items.filter {
            $0.item.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

	init(
		store: Store<ListItems.Reducer>,
		listName: String
	) {
		self.store = store
		self.listName = listName
	}

	var body: some View {
		ZStack {
			itemsList
			newRowButton
			loadingView
		}
		.onAppear {
			store.send(.onAppear)
		}
		.disabled(
			store.state.viewState == .loading
		)
		.navigationBarItems(
			trailing: navigationBarTrailingItems
		)
		.alert(isPresented: alertBinding) {
			Alert(
				title: Text(Constants.Text.errorTitle),
				message: alertErrorMessage,
				dismissButton: .default(Text(Constants.Text.errorOkButton)) {
					store.send(.didTapDismissError)
				}
			)
		}
	}
}

// MARK: - Private

extension ListItemsScreen {
	@ViewBuilder
	fileprivate var navigationBarTrailingItems: some View {
		TDOptionsMenuView(onSort: { store.send(.didTapAutoSortItems) })
	}

	@ViewBuilder
	fileprivate var itemsList: some View {
		ScrollViewReader { scrollView in
			List {
				Section(header: Text(listName).listRowHeaderStyle()) {
					ForEach(
						Array(filteredItems.enumerated()),
						id: \.element.id
					) { index, row in
						if row.isEditing {
							TDNewRowView(
								row: row.tdRow,
								onSubmit: { store.send(.didTapSubmitItemButton($0)) },
								onUpdate: {
									store.send(.didTapUpdateItemButton(index, $0))
								},
								onCancelAdd: { store.send(.didTapCancelAddItemButton) },
								onCancelEdit: {
									store.send(.didTapCancelEditItemButton(index))
								}
							)
							.id(index)
						}
						else {
							TDRowView(
								row: row.tdRow,
								onSwipe: { swipeActions(index, $0) }
							)
							.id(index)
						}
					}.onMove(perform: moveItem)
				}
			}
			.listRowStyle(
				onChangeOf: store.state.viewState == .addingItem,
				count: store.state.viewModel.items.count,
				scrollView: scrollView
			)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
		}
	}

	@ViewBuilder
	fileprivate var newRowButton: some View {
		if store.state.viewState != .addingItem && store.state.viewState != .editingItem {
			TDNewRowButton { store.send(.didTapAddRowButton) }
		}
	}

	@ViewBuilder
	fileprivate var loadingView: some View {
		if store.state.viewState == .loading {
			ProgressView()
		}
	}

	@ViewBuilder
	fileprivate var alertErrorMessage: Text? {
		if case let .error(error) = store.state.viewState {
			Text(error)
		}
	}
}

// MARK: - Private

extension ListItemsScreen {
	fileprivate var swipeActions: (Int, TDSwipeAction) -> Void {
		{ index, option in
			switch option {
			case .done, .undone:
				store.send(.didTapToggleItemButton(index))
			case .delete:
				store.send(.didTapDeleteItemButton(index))
			case .share:
				break
			case .edit:
				store.send(.didTapEditItemButton(index))
			}
		}
	}

	fileprivate func moveItem(fromOffset: IndexSet, toOffset: Int) {
		store.send(.didSortItems(fromOffset, toOffset))
	}

	fileprivate var alertBinding: Binding<Bool> {
		Binding(
			get: {
				if case .error = store.state.viewState {
					return true
				}
				else {
					return false
				}
			},
			set: { _ in }
		)
	}
}

// MARK: - ItemRow to TDRow

extension ListItems.Reducer.ItemRow {
	fileprivate var tdRow: TDRow {
		TDRow(
			name: item.name,
			image: item.done ? Image.largecircleFillCircle : Image.circle,
			strikethrough: item.done,
			leadingActions: leadingActions,
			trailingActions: trailingActions,
			isEditing: isEditing
		)
	}
}

// MARK: - Constants

extension ListItemsScreen {
	fileprivate struct Constants {
		struct Text {
			static let errorTitle = "Error"
			static let errorOkButton = "Ok"
		}
	}
}

#Preview {
	ListItems.Builder.makeItemsList(
		list: UserList(
			documentId: "1",
			name: "Test",
			done: false,
			uid: [""],
			index: 1
		)
	)
}
