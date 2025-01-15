import SwiftUI
import Entities
import Application
import ThemeComponents
import Common
import ListItemsScreenContract

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
	@ObservedObject private var store: Store<ListItems.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    
    private var filteredItems: [ListItems.Reducer.ItemRow] {
        searchText.isEmpty ? store.state.viewModel.items : store.state.viewModel.items.filter {
            $0.item.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

	init(
		store: Store<ListItems.Reducer>
	) {
		self.store = store
	}

	var body: some View {
		ZStack {
			itemsList
			loadingView
		}
		.onAppear {
			store.send(.onAppear)
		}
		.disabled(
			store.state.viewState == .loading
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
	fileprivate var itemsList: some View {
        List {
            Section(header: Text(store.state.viewModel.listName).listRowHeaderStyle()) {
                itemListsHeader
                itemListsContent
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .searchable(
            text: $searchText,
            isPresented: $isSearchFocused,
            placement: .navigationBarDrawer(displayMode: .always)
        )
    }
    
    @ViewBuilder
    fileprivate var itemListsHeader: some View {
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
                store.send(.didTapAutoSortItems)
            }
        }
        .disabled(
            store.state.viewState == .addingItem ||
            store.state.viewState == .editingItem ||
            isSearchFocused
        )
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    fileprivate var itemListsContent: some View {
        ForEach(
            Array(filteredItems.enumerated()),
            id: \.element.id
        ) { index, row in
            if row.isEditing {
                TDNewRowView(
                    row: row.tdRow,
                    onSubmit: { store.send(.didTapSubmitItemButton($0)) },
                    onUpdate: {
                        store.send(.didTapUpdateItemButton(row.id, $0))
                    },
                    onCancelAdd: { store.send(.didTapCancelAddItemButton) },
                    onCancelEdit: {
                        store.send(.didTapCancelEditItemButton(row.id))
                    }
                )
                .id(index)
            }
            else {
                TDRowView(
                    row: row.tdRow,
                    onSwipe: { swipeActions(row.id, $0) }
                )
                .id(index)
            }
        }
        .if(!isSearchFocused) {
            $0.onMove(perform: moveItem)
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
	fileprivate var swipeActions: (UUID, TDSwipeAction) -> Void {
		{ rowId, option in
			switch option {
			case .done, .undone:
				store.send(.didTapToggleItemButton(rowId))
			case .delete:
				store.send(.didTapDeleteItemButton(rowId))
			case .share:
				break
			case .edit:
				store.send(.didTapEditItemButton(rowId))
			}
		}
	}

	fileprivate func moveItem(fromOffset: IndexSet, toOffset: Int) {
        guard !isSearchFocused else { return }
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
            static let newRowButtonTitle = "New Item"
            static let sortButtonTitle = "Sort"
		}
	}
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: ListItemsScreenDependencies {
        var list: UserList
    }
    
    static var previews: some View {
        ListItems.Builder.makeItemsList(
            dependencies: Dependencies(
                list: UserList(
                    documentId: "1",
                    name: "Test",
                    done: false,
                    uid: [""],
                    index: 1
                )
            )
        )
    }
}
