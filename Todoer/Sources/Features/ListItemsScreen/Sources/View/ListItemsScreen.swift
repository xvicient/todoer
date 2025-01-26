import SwiftUI
import Entities
import Application
import ThemeComponents
import Common
import ListItemsScreenContract
import Foundation
import Strings

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
	@ObservedObject private var store: Store<ListItems.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false
    private var isEditing: Bool {
        switch store.state.viewState {
        case .addingItem, .editingItem:
            true
        default:
            false
        }
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
            TDList(
                sections: sections,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                if store.state.viewState == .addingItem {
                    store.send(.didTapCancelAddItemButton)
                } else if case let .editingItem(uid) = store.state.viewState {
                    store.send(.didTapCancelEditItemButton(uid))
                }
            }
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
    
    @ViewBuilder
    func itemsContent() -> AnyView {
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

private extension ListItemsScreen {
    
    var sectionConfiguration: TDListSection.Configuration {
        .init(
            title: store.state.viewModel.listName,
            addButtonTitle: Strings.ListItems.newItemButtonTitle,
            isSortEnabled: store.state.viewModel.items.filter { !$0.isEditing }.count > 1
        )
    }
    
    var sectionActions: TDListSection.Actions {
        .init(
            onAddRow: {
                isSearchFocused = false
                store.send(.didTapAddRowButton)
            },
            onSortRows: { store.send(.didTapAutoSortItems) }
        )
    }
    
    var contentConfiguration: TDListContent.Configuration {
        .init(
            rows: filteredItems.map { $0.tdListRow },
            isMoveEnabled: !isSearchFocused,
            isSwipeEnabled: !isEditing
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
