import SwiftUI
import Entities
import Application
import ThemeComponents
import Common
import ListItemsScreenContract
import Foundation
import Strings

// MARK: - ListItemsScreen

/// The main view for displaying and managing a list of items
/// This screen allows users to view, add, edit, delete, and sort items in a list
struct ListItemsScreen: View {
	@ObservedObject private var store: Store<ListItems.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    
    /// Whether the screen is in editing mode (adding or editing an item)
    private var isEditing: Bool {
        store.state.viewState == .addingItem ||
        store.state.viewState == .editingItem
    }
    
    /// Filtered items based on search text
    private var filteredItems: [ListItems.Reducer.WrappedItem] {
        searchText.isEmpty ? store.state.viewModel.items : store.state.viewModel.items.filter {
            $0.item.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }

    /// Creates a new ListItemsScreen
    /// - Parameter store: The store managing the screen's state and actions
    init(
        store: Store<ListItems.Reducer>
    ) {
        self.store = store
    }

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

// MARK: - ViewBuilders

private extension ListItemsScreen {
    /// Creates the sections of the list
    @ViewBuilder
    func sections() -> AnyView {
        AnyView(
            Group{
                TDListSection(
                    content: itemsContent,
                    configuration: sectionConfiguration,
                    actions: sectionActions
                )
            }
        )
    }
    
    /// Creates the content of the list items
    @ViewBuilder
    func itemsContent() -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration,
                actions: contentActions
            )
        )
    }

    /// Shows a loading indicator when the screen is in loading state
    @ViewBuilder
    var loadingView: some View {
        if store.state.viewState == .loading {
            ProgressView()
        }
    }
}

// MARK: - List configurations

private extension ListItemsScreen {
    /// Configuration for the list section
    var sectionConfiguration: TDListSection.Configuration {
        .init(
            title: store.state.viewModel.listName,
            addButtonTitle: Strings.ListItems.newItemButtonTitle,
            isDisabled: store.state.viewModel.items.isEmpty,
            isEditMode: isEditing
        )
    }
    
    var sectionActions: TDListSection.Actions {
        .init(
            onAddRow: { store.send(.didTapAddRowButton) },
            onSortRows: { store.send(.didTapAutoSortItems) }
        )
    }
    
    var contentConfiguration: TDListContent.Configuration {
        .init(
            rows: filteredItems.map { $0.tdListRow },
            isMoveAllowed: !isSearchFocused
        )
    }
    
    var contentActions: TDListContent.Actions {
        .init(
            onSubmit: { store.send(.didTapSubmitItemButton($0)) },
            onUpdate: { store.send(.didTapUpdateItemButton($0, $1)) },
            onCancelAdd: { store.send(.didTapCancelAddItemButton) },
            onCancelEdit: { store.send(.didTapCancelEditItemButton($0)) },
            onSwipe: swipeActions,
            onMove: moveItem
        )
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
