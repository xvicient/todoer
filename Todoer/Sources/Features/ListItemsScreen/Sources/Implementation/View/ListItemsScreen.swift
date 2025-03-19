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
    @State private var editMode: EditMode = .inactive
    
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
                    else if store.state.viewState == .editingItem {
                        store.send(.didTapCancelEditItemButton)
                    }
                }
            }
            loadingView
        }
        .environment(\.editMode, $editMode)
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
                rows: store.state.filteredItems(isCompleted: source.isCompleted),
                isEditing: Binding(
                    get: { editMode == .active },
                    set: { _ in }
                )
            )
        )
    }

    fileprivate func contentConfiguration(_ listHeight: CGFloat) -> TDListContent.Configuration {
        .init(
            isMoveEnabled: !isSearchFocused && editMode == .active,
            isSwipeEnabled: !store.state.viewState.isEditing && editMode == .inactive,
            listHeight: listHeight
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        TDListContent.Actions(
            onSubmit: { store.send(.didTapSubmitItemButton($0)) },
            onCancel: { store.send(.didTapCancelEditItemButton) },
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
            case .move:
                break
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
            default:
                break
            }
        }
    }

    fileprivate func moveItem(fromOffset: IndexSet, toOffset: Int) {
        store.send(.didMoveItem(fromOffset, toOffset, source.isCompleted))
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
