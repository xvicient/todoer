import Common
import Entities
import Foundation
import ListItemsScreenContract
import Strings
import SwiftUI
import ThemeComponents
import xRedux

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
    @ObservedObject private var store: Store<ListItems.Reducer>
    @State private var searchText = ""
    @State private var isSearchFocused = false

    init(
        store: Store<ListItems.Reducer>
    ) {
        self.store = store
    }

    var body: some View {
        ZStack {
            TDListView(
                sections: sections,
                searchText: $searchText,
                isSearchFocused: $isSearchFocused
            )
            .onChange(of: isSearchFocused) {
                guard isSearchFocused else { return }
                if store.state.viewState == .addingItem {
                    store.send(.didTapCancelAddItemButton)
                }
                else if case let .editingItem(uid) = store.state.viewState {
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

extension ListItemsScreen {

    @ViewBuilder
    fileprivate func sections() -> AnyView {
        AnyView(
            Group {
                TDListSection(
                    configuration: configuration,
                    actions: actions,
                    rows: store.state.viewModel.items.filter(with: searchText).map { $0.tdListRow }
                )
            }
        )
    }

    fileprivate var configuration: TDListSection.Configuration {
        .init(
            title: store.state.viewModel.listName,
            addButtonTitle: Strings.ListItems.newItemButtonTitle,
            isSortEnabled: store.state.viewModel.items.filter { !$0.isEditing }.count > 1,
            isMoveEnabled: !isSearchFocused && !store.state.viewState.isEditing,
            isSwipeEnabled: !store.state.viewState.isEditing
        )
    }

    fileprivate var actions: TDListSection.Actions {
        TDListSection.Actions(
            onAddRow: {
                isSearchFocused = false
                searchText = ""
                store.send(.didTapAddRowButton)
            },
            onSortRows: { store.send(.didTapAutoSortItems) },
            onSubmit: { store.send(.didTapSubmitItemButton($0)) },
            onUpdate: { store.send(.didTapUpdateItemButton($0, $1)) },
            onCancelAdd: { store.send(.didTapCancelAddItemButton) },
            onCancelEdit: { store.send(.didTapCancelEditItemButton($0)) },
            onSwipe: swipeActions,
            onMove: moveItem
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
        guard !isSearchFocused, !store.state.viewState.isEditing else { return }
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
