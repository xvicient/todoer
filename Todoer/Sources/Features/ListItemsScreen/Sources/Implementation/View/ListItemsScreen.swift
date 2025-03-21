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
    
    @EnvironmentObject var loading: TDLoadingModel
    @ObservedObject private var store: Store<ListItems.Reducer>

    init(
        store: Store<ListItems.Reducer>
    ) {
        self.store = store
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                TDListView(
                    configuration: listConfiguration
                ) {
                    listContent(geometry.size.height)
                }
            }
            loadingView
        }
        .environment(\.editMode, $store.editMode)
        .onAppear {
            store.send(.onAppear)
        }
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
            tabs: store.state.tabs,
            activeTab: $store.activeTab,
            searchText: $store.searchText,
            isSearchFocused: $store.isSearchFocused
        )
    }

    @ViewBuilder
    fileprivate func listContent(_ listHeight: CGFloat) -> TDListContent {
        TDListContent(
            configuration: contentConfiguration(listHeight),
            actions: contentActions,
            rows: $store.rows,
            editMode: $store.editMode
        )
    }

    fileprivate func contentConfiguration(_ listHeight: CGFloat) -> TDListContent.Configuration {
        .init(
            lineLimit: 2,
            isMoveEnabled: !store.isSearchFocused && store.editMode.isEditing,
            isSwipeEnabled: !store.isUpdating,
            listHeight: listHeight
        )
    }

    fileprivate var contentActions: TDListContent.Actions {
        TDListContent.Actions(
            onSubmit: { store.send(.didTapSubmitItemButton($0, $1)) },
            onCancel: { store.send(.didTapCancelButton) },
            onSwipe: onSwipe,
            onMove: moveItem
        )
    }
    
    @ViewBuilder
    fileprivate var loadingView: some View {
        if store.isLoading {
            ProgressView()
        }
    }
}

// MARK: - Private

extension ListItemsScreen {
    
    fileprivate var onSwipe: (UUID, TDSwipeAction) -> Void {
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
        store.send(.didMoveItem(fromOffset, toOffset))
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
