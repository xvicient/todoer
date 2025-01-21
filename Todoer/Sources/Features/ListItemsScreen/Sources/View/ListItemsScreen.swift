import SwiftUI
import Entities
import Application
import ThemeComponents
import Common
import ListItemsScreenContract
import Foundation

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
	@ObservedObject private var store: Store<ListItems.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    private var isEditing: Bool {
        store.state.viewState == .addingItem ||
        store.state.viewState == .editingItem
    }
    
    private var filteredItems: [ListItems.Reducer.WrappedItem] {
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
        .alert(item: store.alertBinding) {
            $0.alert { store.send($0) }
        }
	}
}

// MARK: - Private

extension ListItemsScreen {
    
    private var itemsSectionConfiguration: TDListSection.Configuration {
        .init(
            title: store.state.viewModel.listName,
            addButtonTitle: ListItems.Strings.newRowButtonTitle,
            isDisabled: store.state.viewModel.items.isEmpty,
            isEditMode: isEditing
        )
    }
    
    private var itemsSectionActions: TDListSection.Actions {
        .init(
            onAddRow: { store.send(.didTapAddRowButton) },
            onSortRows: { store.send(.didTapAutoSortItems) }
        )
    }
    
	@ViewBuilder
	fileprivate var itemsList: some View {
        List {
            TDListSection(
                content: itemsContent,
                configuration: itemsSectionConfiguration,
                actions: itemsSectionActions
            )
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .if(!isEditing) {
            $0.searchable(
                text: $searchText,
                isPresented: $isSearchFocused,
                placement: .navigationBarDrawer(displayMode: .always)
            )
        }
    }
    
    private var itemsContentConfiguration: TDListContent.Configuration {
        .init(
            rows: filteredItems.map { $0.tdListRow },
            isMoveAllowed: !isSearchFocused
        )
    }
    
    private var itemsContentActions: TDListContent.Actions {
        .init(
            onSubmit: { store.send(.didTapSubmitItemButton($0)) },
            onUpdate: { store.send(.didTapUpdateItemButton($0, $1)) },
            onCancelAdd: { store.send(.didTapCancelAddItemButton) },
            onCancelEdit: { store.send(.didTapCancelEditItemButton($0)) },
            onSwipe: swipeActions,
            onMove: moveItem
        )
    }
    
    @ViewBuilder
    fileprivate func itemsContent() -> AnyView {
        AnyView(
            TDListContent(
                configuration: itemsContentConfiguration,
                actions: itemsContentActions
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
}

// MARK: - ItemRow to TDRow

extension ListItems.Reducer.WrappedItem {
	fileprivate var tdListRow: TDListRow {
		TDListRow(
            id: item.id,
            name: item.name,
			image: item.done ? Image.largecircleFillCircle : Image.circle,
			strikethrough: item.done,
			leadingActions: leadingActions,
			trailingActions: trailingActions,
			isEditing: isEditing
		)
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
                    id: UUID(),
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
