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
    @FocusState private var isSearchFocused: Bool

    init(
        store: Store<ListItems.Reducer>
    ) {
        self.store = store
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                TDListView(
                    content: { listContent(geometry.size.height) },
                    actions: listActions,
                    configuration: listConfiguration,
                    searchText: $searchText,
                    isSearchFocused: $isSearchFocused,
                    activeTab: Binding(
                        get: { .all },
                        set: { _ in }
                    )
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
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: store.state.viewModel.listName,
            tabs: TDListTab.allCases
                .removingSort(if: store.state.viewModel.items.filter { !$0.isEditing }.count < 2)
                .filter { !$0.isFilter }
        )
    }

    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration(listHeight),
                actions: contentActions,
                rows: store.state.viewModel.items.filter(with: searchText).map { $0.tdListRow }
            )
        )
    }

    fileprivate func contentConfiguration(_ listHeight: CGFloat) -> TDListContent.Configuration {
        .init(
            isMoveEnabled: !isSearchFocused && !store.state.viewState.isEditing,
            isSwipeEnabled: !store.state.viewState.isEditing,
            listHeight: listHeight
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        TDListContent.Actions(
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
    fileprivate var listActions: (TDListTab) -> Void {
        { action in
            switch action {
            case .add:
                {
                    isSearchFocused = false
                    searchText = ""
                    store.send(.didTapAddRowButton)
                }()
            case .sort:
                store.send(.didTapAutoSortItems)
            default:
                break
            }
        }
    }
    
    fileprivate var swipeActions: (UUID, TDSwipeAction) -> Void {
        { rowId, option in
            switch option {
            case .done, .undone:
                store.send(.didTapToggleItemButton(rowId))
            case .delete:
                store.send(.didTapDeleteItemButton(rowId))
            case .edit:
                store.send(.didTapEditItemButton(rowId))
            default:
                break
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
