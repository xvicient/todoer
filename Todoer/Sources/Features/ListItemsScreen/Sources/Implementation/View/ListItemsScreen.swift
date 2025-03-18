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
    @FocusState private var isSearchFocused: Bool
    @State private var source: TDListTab = .all
    
    private var activeTabBinding: Binding<TDListTab> {
        Binding(
            get: { source.activeTab },
            set: { _ in }
        )
    }

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
                    searchText: Binding(
                        get: { store.state.searchText },
                        set: { store.send(.didUpdateSearchText($0)) }
                    ),
                    isSearchFocused: $isSearchFocused,
                    activeTab: activeTabBinding
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
            title: store.state.listName,
            tabs: store.state.tabs
        )
    }

    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> AnyView {
        AnyView(
            TDListContent(
                configuration: contentConfiguration(listHeight),
                actions: contentActions,
                rows: store.state.filteredItems(isCompleted: source.isCompleted)
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
                source = .all
                return {
                    isSearchFocused = false
                    store.send(.didUpdateSearchText(""))
                    store.send(.didTapAddRowButton)
                }()
            case .sort:
                store.send(.didTapAutoSortItems)
            case .all:
                source = .all
            case .done:
                source = .done
            case .todo:
                source = .todo
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
