import Common
import Entities
import ListItemsScreenContract
import SwiftUI
import ThemeComponents
import xRedux
import EntitiesMocks

// MARK: - ListItemsScreen

struct ListItemsScreen: View {
    
    @Bindable private var store: Store<ListItemsReducer>

    init(
        store: Store<ListItemsReducer>
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

// MARK: - TDListView

extension ListItemsScreen {
    fileprivate var listConfiguration: TDListView.Configuration {
        .init(
            title: store.state.listName,
            tabs: $store.tabs,
            activeTab: $store.activeTab,
            searchText: $store.searchText,
            isSearchFocused: $store.isSearchFocused
        )
    }

    fileprivate func listContent(_ listHeight: CGFloat) -> TDListContentView {
        let configuration = TDListContentView.Configuration(
            listHeight: listHeight,
            status: store.contentStatus
        )
        
        let actions = TDListContentView.Actions(
            onSubmit: { store.send(.didTapSubmitItemButton($0, $1)) },
            onSwipe: onSwipe,
            onMove: { store.send(.didMoveItem($0, $1)) }
        )
        
        return TDListContentView(
            configuration: configuration,
            actions: actions,
            rows: $store.rows
        )
    }
    
    fileprivate var onSwipe: (String, TDListSwipeAction) -> Void {
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
    
    @ViewBuilder
    fileprivate var loadingView: some View {
        if store.isLoading {
            ProgressView()
        }
    }
}

struct Home_Previews: PreviewProvider {
    struct Dependencies: ListItemsScreenDependencies {
        var list: UserList
    }
    
    static var previews: some View {
        ListItemsBuilder.makeItemsList(
            dependencies: Dependencies(
                list: ListMock.list
            )
        )
    }
}
